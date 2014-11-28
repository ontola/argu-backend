class StaticPagesController < ApplicationController

  def home
    authorize :static_pages
  	if signed_in?
      redirect_to current_profile.memberships.first.forum
  	else
  		render 'static_pages/about', layout: 'layouts/closed', locals: {show_sign_in: true}
	  end
  end

  def sign_in_modal
    authorize :static_pages
    @resource ||= User.new
    render 'devise/sessions/new', layout: false, locals: {resource: @resource, resource_name: :user, devise_mapping: Devise.mappings[:user]}
  end

  def about
    authorize :static_pages
  end

  def developers
    authorize :static_pages
  end
end
