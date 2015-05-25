class PredictionController < ApplicationController
	
	def show_lat_long
		@hash = Prediction.predict_latlong(params[:period], params[:lat], params[:long])
	    respond_to do |format|
	      format.html
	      format.json { render json: JSON.pretty_generate(@hash) }
	    end
	end
	
	def show_postcode
		@hash = Prediction.predict_postcode(params[:postcode], params[:period])
		respond_to do |format|
	      format.html
	      format.json { render json: JSON.pretty_generate(@hash) }
	    end
	end
end
