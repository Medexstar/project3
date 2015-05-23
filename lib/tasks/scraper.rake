require 'nokogiri'
require 'open-uri'
require 'json'

BOM_BASE_URL = 'http://www.bom.gov.au'


namespace :scrape do

	# Update the locations in the DB from BOM. Marks any locations that have disappeared as inactive.
	task :seed_locations => :environment do
		doc = Nokogiri::HTML(open("#{BOM_BASE_URL}/vic/observations/vicall.shtml"))
		url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='
		api = 'key=AIzaSyC_ah2e2ctcBDwIYBZ1O8laWOpguNeBx5I'
		
		# Get the list of locations from BOM.
		location_nodes = doc.css("th[id*=-station-]").map
		location_nodes.each do |location_node|
			# Find the location's information
			location_doc = Nokogiri.HTML(open("#{BOM_BASE_URL}#{location_node.css("a")[0]["href"]}"))
			station_details = location_doc.css("table[class=stationdetails]").first.text
			station_details.match(/Lat:\s*(-?\d+\.\d+)\s+Lon:\s*(-?\d+\.\d+)/)
			name = location_node.text
			
			#Remove observation stations with unobtainable postcodes
			if name == "Kingfish B" || name == "Hogan Island" || name == "Mount Hotham AWS"
				next
			end
			
			lat = $1.to_f
			long = $2.to_f
			location_doc.css("table.stationdetails td")[2].text.match(/Name: ([A-Z\s]*)/)
			id = $1.strip
			googlemaps = JSON.parse(open("#{url}#{lat},#{long}&#{api}").read)
			postcode = googlemaps["results"][0]["address_components"][-1]["long_name"]
			# Update the location in the DB.
			location = Location.find_or_initialize_by(name: name)
			location.location_id = id
			location.lat = lat
			location.long = long
			location.postcode = postcode
			location.save if location.changed?
		end
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