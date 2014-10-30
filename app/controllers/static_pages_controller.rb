class StaticPagesController < ApplicationController
  
  def home
    authorize :static_pages
  	if signed_in?
      @questions = policy_scope(Question.index params[:trashed], params[:page])
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
