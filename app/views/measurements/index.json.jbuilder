json.array!(@measurements) do |measurement|
  json.extract! measurement, :id, :temp, :percip_intensity, :wind_speed, :wind_direction, :time
  json.url measurement_url(measurement, format: :json)
end
