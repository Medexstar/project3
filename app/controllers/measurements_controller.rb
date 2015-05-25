class MeasurementsController < ApplicationController
  
  def show_location_id
    location = Location.find_by(location_id: params[:location_id])
    @hash = location.measurement_data(params[:date])
    respond_to do |format|
      format.html
      format.json { render json: JSON.pretty_generate(@hash) }
    end
  end
  
  def show_postcode
    @hash = Location.postcode_data(params[:post_code], params[:date])
    respond_to do |format|
      format.html
      format.json { render json: JSON.pretty_generate(@hash) }
    end
  end
end
