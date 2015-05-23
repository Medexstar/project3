class LocationsController < ApplicationController
	before_action :set_location, only: [:show, :edit, :update, :destroy]

	# GET /locations
	# GET /locations.json
	def index
		@hash = Location.get_all_locations
		respond_to do |format|
			format.html
			format.json { render json: @hash }
		end
	end
	
	def show_location_id
		location = Location.find_by(location_id: params[:location_id])
		@hash = location.measurement_data params[:date]
		respond_to do |format|
			format.html
			format.json { render json: @hash }
		end
	end

	private
		# Use callbacks to share common setup or constraints between actions.
		def set_location
			@location = Location.find(params[:id])
		end

		# Never trust parameters from the scary internet, only allow the white list through.
		def location_params
			params.require(:location).permit(:name, :lat, :long, :postcode)
		end
end
