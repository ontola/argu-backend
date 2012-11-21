class SearchController < ApplicationController

	def show
	    @search = Statement.search do
	    	fulltext params['q']
	    end
	    

	    respond_to do |format|
	    	format.html # show.html.erb
	    	format.json { render json: search.results }
	    end
  	end
end