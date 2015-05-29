class Prediction < ActiveRecord::Base
	def self.predict_latlong period, lat, long
		location = Location.get_nearest_location(lat, long)[0]
		if !location.last_update
			return {}
		end
		data_hash = {}
		result_hash = {:lattitude => lat, :longitude => long, :predictions => {}}
		first_measurement = location.measurements.first.timestamp
		
		get_data(location.measurements.all, data_hash, first_measurement)
		
		make_prediction(data_hash, period, result_hash, first_measurement)
		return result_hash
	end
	
	def self.predict_postcode code, period
		if postcode = Postcode.find_by(code: code)
			locations = postcode.get_locations
		else
			postcode = Postcode.new_postcode(code)
			locations = postcode.get_locations
		end
		@current_time = Time.now
		data_hash = {}
		result_hash = {:postcode => code, :predictions => {}}
		first_measurement = Time.now
		locations.each do |location|
			location.measurements.each do |measurement|
				if measurement.timestamp < first_measurement && measurement.timestamp >= @current_time - 43200
					first_measurement = measurement.timestamp
				end
			end
		end
		locations.each do |location|
			get_data(location.measurements.all, data_hash, first_measurement)
		end
		
		make_prediction(data_hash, period, result_hash, first_measurement)
		return result_hash
	end
	
	def self.get_data measurements, data_hash, first_measurement
		
		measurements.each do |data_point|
			if data_point.timestamp < @current_time - 43200
				next
			end
			timestamp = ((data_point.timestamp - first_measurement)/60)+1
			if !data_hash.has_key?(timestamp)
				data_hash[timestamp] = {:rainfall => data_point.precip_intensity, :temp => data_point.temp, :winddir => data_point.wind_direction, :windspeed => data_point.wind_speed}
			else
				data_hash[timestamp][:rainfall] = (data_hash[timestamp][:rainfall] + data_point.precip_intensity)/2
				data_hash[timestamp][:temp] = (data_hash[timestamp][:temp] + data_point.temp)/2
				data_hash[timestamp][:winddir] = (data_hash[timestamp][:winddir] + data_point.wind_direction)/2
				data_hash[timestamp][:windspeed] = (data_hash[timestamp][:windspeed] + data_point.wind_speed)/2
			end	
		end
	end
	
	def self.make_prediction data_hash, period, hash, first_measurement
		current_time = Time.now
		time_difference = current_time - first_measurement
		names = [:rain, :temp, :wind_direction, :wind_speed]
		rainfall_array, temp_array, winddir_array, windspeed_array, time_array = [], [] ,[] ,[], []
		
		data_hash.each do |time, measurements|
			time_array << time
			rainfall_array << measurements[:rainfall]
			temp_array << measurements[:temp]
			winddir_array << measurements[:winddir]
			windspeed_array << measurements[:windspeed]
		end

		(0..period.to_i/10).each do |time|
			count = 0
			hash[:predictions][(time*10).to_s] = {:time => (current_time + (time*10*60)).strftime("%-l:%M%P %d-%m-%Y")}
			[rainfall_array, temp_array, winddir_array, windspeed_array].each do |y_array|
				reg = Regression.calc_best_regression(time_array, y_array)
				value = reg.calc_prediction((time_difference/60 + time*10)+1)
				if y_array == winddir_array
					value = (value % 360).round(2)
				else
					value = value.round(2)
				end
				hash[:predictions][(time*10).to_s][names[count]] = {:value => value.to_s, :probability => reg.r_sqrd.to_s}
				count += 1
			end
		end
	end
end
