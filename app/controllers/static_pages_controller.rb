class StaticPagesController < ApplicationController
  
  def home
    authorize :static_pages
  	if signed_in?
      @newstatements = Statement.index params[:trashed], params[:page]
  		render 'static_pages/home'
  	else
  		render 'static_pages/home_new'
	  end
  end
  def about
    authorize :static_pages
  end

  def developers
  end
end
