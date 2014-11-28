class StaticPagesController < ApplicationController

  def home
    authorize :static_pages
  	if signed_in?
      redirect_to default_forum_path
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

  private
  def default_forum_path
    if current_profile.present? && defined?(current_profile.memberships) && !current_profile.memberships.empty?
      current_profile.memberships.first.forum
    else
      Forum.first_public
    end
  end
end
