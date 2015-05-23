class Location < ActiveRecord::Base
	has_many :measurements
	# self.primary_key = :id
	
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
		hash[:measurements] = []
		self.measurements.each do |measurement|
			if measurement.timestamp.to_date == date.to_date
				hash[:measurements] << measurement.to_json
			end
		end
		return hash
	end
	
	def to_json
		{:id => self.location_id.to_s, :lat => self.lat.to_s, :long => self.long.to_s, :last_updated => self.last_update.to_s}
	end
end
