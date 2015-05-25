 class LocationsController < ApplicationController
 	
	def index
		@hash = Location.get_all_locations
		respond_to do |format|
			format.html
			format.json { render json: JSON.pretty_generate(@hash) }
		end
	end
end
