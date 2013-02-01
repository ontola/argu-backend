class StaticPagesController < ApplicationController
  
  include StaticPagesHelper

  def home
  	if signed_in?
      @newstatements = Statement.all.sort_by { |s| s.arguments.size }.reverse
  		render 'static_pages/home'
  	else
  		render 'static_pages/home_new'
	  end
  end
  def about
  end
  def learn
  end
end
