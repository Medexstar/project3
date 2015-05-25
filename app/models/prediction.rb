class Prediction < ActiveRecord::Base
	def self.predict location, period
		if !location.last_update
			return {}
		end
		current_time = Time.now
		time_difference = current_time - location.measurements.first.timestamp
		hash = {:location_id => location.location_id, :predictions => {}}
		data = location.measurements.all
		rainfall_array, temp_array, winddir_array, windspeed_array, time_array = [], [] ,[] ,[] ,[]
		
		data.each do |data_point|
			rainfall_array << data_point.precip_intensity
			temp_array << data_point.temp
			winddir_array << data_point.wind_direction
			windspeed_array << data_point.wind_speed
			time_array << (data_point.timestamp - location.measurements.first.timestamp)/60
		end
		
		names = [:rain, :temp, :wind_direction, :wind_speed]
		
		(0..period.to_i/10).each do |time|
			count = 0
			hash[:predictions][(time*10).to_s] = {:time => (current_time + (time*10*60)).strftime("%-l:%M%P %d-%m-%Y")}
			[rainfall_array, temp_array, winddir_array, windspeed_array].each do |y_array|
				reg = Regression.calc_best_regression(time_array, y_array)
				value = reg.coefficients
				hash[:predictions][(time*10).to_s][names[count]] = {:value => value.to_s, :probability => reg.r_sqrd.to_s}
				count += 1
			end
		end
		return hash
	end
end
