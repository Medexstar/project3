class PredictionController < ApplicationController
	
	def show_lat_long
		@location = Location.get_nearest_location(params[:lat], params[:long])
		@hash = Prediction.predict(@location, params[:period])
	    respond_to do |format|
	      format.html
	      format.json { render json: JSON.pretty_generate(@hash) }
	    end
	end
end
