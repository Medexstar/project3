class PredictionController < ApplicationController
	
	def show_lat_long
		@location = Location.get_nearest_location(params[:lat], params[:long])[0]
		@hash = Prediction.predict(@location, params[:period], params[:lat], params[:long])
	    respond_to do |format|
	      format.html
	      format.json { render json: JSON.pretty_generate(@hash) }
	    end
	end
	
	def show_postcode
		@location = Location.get_nearest_location(params[:postcode])
		@hash = Prediction.predict_postcode(params[:postcode], params[:period])
		respond_to do |format|
	      format.html
	      format.json { render json: JSON.pretty_generate(@hash) }
	    end
	end
end
