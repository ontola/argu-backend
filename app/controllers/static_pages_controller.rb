class StaticPagesController < ApplicationController
  include StaticPagesHelper

  def home
  	if signed_in?
  		@newstatements = Statement.today
  		@newarguments = Argument.today
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
