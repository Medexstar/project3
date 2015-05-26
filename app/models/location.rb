require 'open-uri'
require 'json'

class Location < ActiveRecord::Base
	has_many :measurements
	belongs_to :postcode
	
	def self.get_all_locations
		hash = {:date => Date.today.strftime("%d-%m-%Y"), :locations => []}
		locations = Location.all
		locations.each do |location|
			hash[:locations] << location.to_json
		end
		return hash
	end
	
	def measurement_data date
		hash = {:date => date}
		if Time.now - self.last_update > 1800
			hash[:current_temp] = nil
			hash[:current_cond] = nil
		else
			hash[:current_temp] = self.measurements.last.temp
			hash[:current_cond] = self.summary
		end
		measurements = get_measurements(date)
		hash[:measurements] = measurements
		return hash
	end
	
	def self.postcode_data code, date
		hash = {:date => date, :locations => []}
		postcode = Postcode.where(code: code)
		locations = Location.where(postcode: postcode)
		locations.each do |location|
			measurements = location.get_measurements(date)
			hash[:locations] << location.to_json(measurements)
		end
		return hash
	end
	
	def to_json *args
		if args.length == 0
			{:id => self.location_id.to_s, :lat => self.lat.to_s, :lon => self.long.to_s, :last_update => self.last_update ? self.last_update.strftime("%-l:%M%P %d-%m-%Y") : self.last_update}
		elsif args.length == 1
			{:id => self.location_id.to_s, :lat => self.lat.to_s, :lon => self.long.to_s, :last_update => self.last_update ? self.last_update.strftime("%-l:%M%P %d-%m-%Y") : self.last_update, :measurements => args[0]}
		end
	end
	
	def get_measurements date
		measurements = []
		self.measurements.each do |measurement|
			if measurement.timestamp.to_date == date.to_date
				measurements << measurement.to_json
			end
		end
		return measurements
	end
	
	def self.get_nearest_location lat, long
		loc1 = [lat.to_f, long.to_f]
		locations = Location.all
		min_distance = Float::INFINITY
		nearest_location = nil
		locations.each do |location|
			loc2 = [location.lat, location.long]
			distance = haversine_distance(loc1, loc2)
			if distance < min_distance
				min_distance = distance
				nearest_location = location
			end
		end
		return [nearest_location]
	end
	
	def self.haversine_distance loc1, loc2
	  rad_per_deg = Math::PI/180  # PI / 180
	  rkm = 6371                  # Earth radius in kilometers
	  rm = rkm * 1000             # Radius in meters

	  dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
	  dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg

	  lat1_rad = loc1[0] * rad_per_deg
	  lat2_rad = loc2[0] * rad_per_deg

	  a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
	  c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

	  rm * c # Delta in meters
	end
end
