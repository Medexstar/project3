require 'nokogiri'
require 'open-uri'
require 'json'

BOM_BASE_URL = 'http://www.bom.gov.au'


namespace :scrape do

	# Update the locations in the DB from BOM. Marks any locations that have disappeared as inactive.
	task :seed_locations => :environment do
		doc = Nokogiri::HTML(open("#{BOM_BASE_URL}/vic/observations/vicall.shtml"))
		url = 'https://maps.googleapis.com/maps/api/geocode/json?'
		api = 'key=AIzaSyC_ah2e2ctcBDwIYBZ1O8laWOpguNeBx5I'
		
		# Get the list of locations from BOM.
		puts "Seeding locations from BOM"
		location_nodes = doc.css("th[id*=-station-]").map
		location_nodes.each do |location_node|
			name = location_node.text
			if Location.find_by(name: name)
				next
			end
			html_id = location_node["id"]
			# Find the location's information
			location_doc = Nokogiri.HTML(open("#{BOM_BASE_URL}#{location_node.css("a")[0]["href"]}"))
			station_details = location_doc.css("table[class=stationdetails]").first.text
			station_details.match(/Lat:\s*(-?\d+\.\d+)\s+Lon:\s*(-?\d+\.\d+)/)
			
			#Remove observation stations with unobtainable postcodes
			if name == "Kingfish B" || name == "Hogan Island" || name == "Mount Hotham AWS"
				next
			end
			
			puts "Seeding Station: #{name}"
			
			lat = $1.to_f
			long = $2.to_f
			location_doc.css("table.stationdetails td")[2].text.match(/Name: ([A-Z\s]*)/)
			id = $1.strip
			id.tr!(' ','_')
			googlemaps = JSON.parse(open("#{url}latlng=#{lat},#{long}&#{api}").read)
			code = googlemaps["results"][0]["address_components"][-1]["long_name"]
			components = "components=postal_code:#{code}|country:AU"
			
			googlemaps = JSON.parse(open(URI.encode("#{url}#{components}&#{api}")).read)
			post_lat = googlemaps["results"][0]["geometry"]["location"]["lat"]
			post_long = googlemaps["results"][0]["geometry"]["location"]["lng"]
			# Update the location in the DB.
			location = Location.find_or_initialize_by(name: name)
			postcode = Postcode.find_or_initialize_by(code: code)
			postcode.lat = post_lat
			postcode.long = post_long
			postcode.save if postcode.changed?

			location.location_id = id
			location.lat = lat
			location.long = long
			location.postcode = postcode
			location.html_id = html_id
			location.save if location.changed?
		end
	end
	
	task :bom => :environment do
		puts "Scraping data from BOM site"
		doc = Nokogiri::HTML(open("#{BOM_BASE_URL}/vic/observations/vicall.shtml"))
		Location.all.each do |location|
			id = location.html_id
			puts "Scraping Station: #{location.name}"
			data = doc.css("td[headers~=#{id}]")
		 
			if (data.empty?)
				puts "test"
				next
			else
			 	new_temp = data[1].text
			 	new_rainfall = data[12].text
			 	new_wind_speed = data[7].text
			 	new_wind_direction = data[6].text
			 	new_time = data[0].text
			end
			
			measurement = Measurement.new(
				temp: new_temp,
				precip_intensity: new_rainfall,
				wind_speed: new_wind_speed,
				wind_direction: cardinal_direction_degrees(new_wind_direction),
				timestamp: new_time
			)
			measurement.location = location
			location.last_update = measurement.timestamp
			location.summary = "Shitty"
			if !location.measurements.exists?(:timestamp => measurement.timestamp)
				measurement.save
				location.save
			end
		end
	end
	
	def cardinal_direction_degrees cardinal
	 	hash = {n: 0, nne: 22.5, ne: 45, ene: 67.5, e: 90, ese: 112.5, se: 135, sse: 157.5, s: 180, ssw: 202.5, sw: 225, wsw: 247.5, w: 270, wnw: 292.5, nw: 315, nnw: 337.5}
	 	hash[cardinal.to_s.downcase.to_sym]
	end

	#Scrape data from forecast into DB
	task :forecast => :environment do
		@locations = Location.all
		url = 'https://api.forecast.io/forecast/'
		api = '5fb7e03636ea88de68d960a0862dcb92'
		options = '?units=ca&exclude=minutely,hourly,daily,alerts,flags'
		
		@locations.each do |location|
			forecast = JSON.parse(open("#{url}#{api}/#{location.lat},#{location.long}#{options}").read)
			current_data = forecast["currently"].to_hash.with_indifferent_access
			
			measurement = Measurement.new(
				temp: current_data[:temperature],
				precip_intensity: current_data[:precipIntensity],
				wind_speed: current_data[:windSpeed],
				wind_direction: current_data[:windBearing],
				timestamp: Time.at(current_data[:time])
			)
			measurement.location = location
			location.last_update = measurement.timestamp
			location.summary = current_data[:summary]
			location.save
			measurement.save
		end
	end
end