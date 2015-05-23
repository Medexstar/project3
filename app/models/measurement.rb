class Measurement < ActiveRecord::Base
	belongs_to :location
	
	def to_json
		{:time => self.timestamp.strftime("%-l:%M:%S %P"), :temp => self.temp.to_s, :precip => self.precip_intensity.to_s + "mm", :wind_direction => self.wind_direction.to_s, :wind_speed => self.wind_speed.to_s}
	end
end
