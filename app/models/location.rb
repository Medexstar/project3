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
		measurements = get_measurements(date)
		hash[:measurements] = measurements
		return hash
	end
	
	def self.postcode_data postcode, date
		hash = {:date => date, :locations => []}
		locations = Location.where(postcode: postcode)
		locations.each do |location|
			measurements = location.get_measurements(date)
			hash[:locations] << location.to_json(measurements)
		end
		return hash
	end
	
	def to_json
		{:id => self.location_id.to_s, :lat => self.lat.to_s, :lon => self.long.to_s, :last_update => self.last_update ? self.last_update.strftime("%-l:%M%P %d-%m-%Y") : self.last_update}
	end
	
	def to_json measurements
		{:id => self.location_id.to_s, :lat => self.lat.to_s, :lon => self.long.to_s, :last_update => self.last_update ? self.last_update.strftime("%-l:%M%P %d-%m-%Y") : self.last_update, :measurements => measurements}
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
end
