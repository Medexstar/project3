require 'nokogiri'
require 'open-uri'
require 'json'

BOM_BASE_URL = 'http://www.bom.gov.au'


namespace :scrape do

  # Update the locations in the DB from BOM. Marks any locations that have disappeared as inactive.
  task :seed_locations => :environment do
  	puts "test"
	doc = Nokogiri::HTML(open("#{BOM_BASE_URL}/vic/observations/vicall.shtml"))
    # Get the list of locations from BOM.
    doc.css("th[id*=-station-]").each do |location_node|
      # Find the location's information
      location_doc = Nokogiri.HTML(open("#{BOM_BASE_URL}#{location_node.attr :href}"))
      station_details = location_doc.css("table[class=stationdetails]").first.text
      #station_details.match(/Lat:\s*(-?\d+\.\d+)\s+Lon:\s*(-?\d+\.\d+)/)
      puts "#{station_details}"
      name = location_node.text
      lat = $1.to_f
      lon = $2.to_f

      # Update the location in the DB.
      #location = Location.find_or_initialize_by(name: name)
      #location.lat = lat
      #location.lon = lon
      #location.save if location.changed?
      puts "#{name}"
    end
  end
end
