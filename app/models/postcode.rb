class Postcode < ActiveRecord::Base
	has_many :locations

	def self.new_postcode postcode
		url = 'https://maps.googleapis.com/maps/api/geocode/json?'
		api = 'key=AIzaSyC_ah2e2ctcBDwIYBZ1O8laWOpguNeBx5I'
		components = "components=postal_code:#{postcode}|country:AU"
		
		googlemaps = JSON.parse(open(URI.encode("#{url}#{components}&#{api}")).read)
		lat = googlemaps["results"][0]["geometry"]["location"]["lat"]
		long = googlemaps["results"][0]["geometry"]["location"]["lng"]
		return Postcode.create(code: postcode, lat: lat, long: long)
	end

	def get_locations
		if self.locations.size != 0
			return self.locations.all
		else
			return Location.get_nearest_location(self.lat, self.long)
		end
	end
end
