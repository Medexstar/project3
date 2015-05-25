class Prediction < ActiveRecord::Base
	def self.predict location, period, lat, long
		if !location.last_update
			return {}
		end
		current_time = Time.now
		time_difference = current_time - location.measurements.first.timestamp
		hash = {:lattitude => lat, :longitude => long, :predictions => {}}
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
				value = reg.calc_prediction(time_difference/60 + time*10).round(2)
				hash[:predictions][(time*10).to_s][names[count]] = {:value => value.to_s, :probability => reg.r_sqrd.to_s}
				count += 1
			end
		end
		return hash
	end
	
	def self.predict_postcode postcode, period
		if Location.find_by(postcode: postcode)
			locations = Location.where(postcode: postcode)
		else
			locations = Location.get_nearest_location(postcode)
		end
		data_hash = {}
		result_hash = {:postcode => postcode, :predictions => {}}
		rainfall_array, temp_array, winddir_array, windspeed_array, time_array = [], [] ,[] ,[] ,[]
		first_measurement = Time.now
		locations.each do |location|
			if location.measurements.first.timestamp < first_measurement
				first_measurement = location.measurements.first.timestamp
			end
		end
		locations.each do |location|
			get_data(location.measurements.all, data_hash, first_measurement)
		end
		data_hash.each do |time, measurements|
			time_array << time
			rainfall_array << measurements[:rainfall]
			temp_array << measurements[:temp]
			winddir_array << measurements[:winddir]
			windspeed_array << measurements[:windspeed]
		end
		
		make_prediction(rainfall_array, temp_array, winddir_array, windspeed_array, time_array, period, result_hash, first_measurement)
		return result_hash
	end
	
	def self.get_data measurements, data_hash, first_measurement
		
		measurements.each do |data_point|
			data_hash[(data_point.timestamp - first_measurement)/60] = {:rainfall => data_point.precip_intensity, :temp => data_point.temp, :winddir => data_point.wind_direction, :windspeed => data_point.wind_speed}
		end
	end
	
	def self.make_prediction rainfall_array, temp_array, winddir_array, windspeed_array, time_array, period, hash, first_measurement
		current_time = Time.now
		time_difference = current_time - first_measurement
		names = [:rain, :temp, :wind_direction, :wind_speed]
		
		(0..period.to_i/10).each do |time|
			count = 0
			hash[:predictions][(time*10).to_s] = {:time => (current_time + (time*10*60)).strftime("%-l:%M%P %d-%m-%Y")}
			[rainfall_array, temp_array, winddir_array, windspeed_array].each do |y_array|
				reg = Regression.calc_best_regression(time_array, y_array)
				value = reg.calc_prediction(time_difference/60 + time*10).round(2)
				hash[:predictions][(time*10).to_s][names[count]] = {:value => value.to_s, :probability => reg.r_sqrd.to_s}
				count += 1
			end
		end
	end
end
