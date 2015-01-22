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
    respond_to do |format|
      format.js { render 'devise/sessions/new', layout: false, locals: {resource: @resource, resource_name: :user, devise_mapping: Devise.mappings[:user]} }
      format.html { render 'devise/sessions/new', layout: 'closed', locals: {resource: @resource, resource_name: :user, devise_mapping: Devise.mappings[:user]} }
    end
  end

  def about
    authorize :static_pages
  end

  def product
    authorize :static_pages
  end

  def developers
    authorize :static_pages
  end

  private
  def default_forum_path
    current_profile.present? ? current_profile.preferred_forum : Forum.first_public
  end
end
