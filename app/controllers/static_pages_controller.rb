class StaticPagesController < ApplicationController
  
  include StaticPagesHelper

  def home
  	if signed_in?
      @newstatements = Statement.index params[:trashed], params[:page]
  		render 'static_pages/home'
  	else
  		render 'static_pages/home_new'
	  end
  end
  def about
  end

  def developers
  end
end
