class SearchController < ApplicationController

	def show
		begin
	    @search = Motion.search do
	    	fulltext params['q']
	    	paginate page: params[:page]
	    end
	    
	    respond_to do |format|
	    	format.html # show.html.erb
	    	format.json { render json: search.results }
	    end
	    
	    rescue Errno::ECONNREFUSED
	    	respond_to do |format|
	    		format.html { redirect_to :back, notice: "Zoekfunctie tijdelijk niet beschikbaar" }
	    		format.json { head :no_content }
	    	end
		end
  	end
end