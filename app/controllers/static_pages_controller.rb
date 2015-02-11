class StaticPagesController < ApplicationController
  before_action :get_document, only: [:team, :about, :product]

  def home
    authorize :static_pages
  	if signed_in?
      if policy(current_user).staff?
        @activities = policy_scope(Activity).order(created_at: :desc).limit(10)
        render
      else
        redirect_to preferred_forum
      end
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

  def how_argu_works
    authorize :static_pages
  end

  def team
    authorize :static_pages
  end

  private
  def default_forum_path
    current_profile.present? ? preferred_forum : Forum.first_public
  end

  def get_document
    @document = JSON.parse Setting.get(params[:action]) || '{}'
    # parsing is neccessary, since the _simple_settings gem converts the JSON to a string
  end

end
