class StaticPagesController < ApplicationController

  def home
    authorize :static_pages
  	if signed_in? || within_user_cap?
      if current_user && policy(current_user).staff?
        @activities = policy_scope(Activity).order(created_at: :desc).limit(10)
        render #stream: true
      else
        redirect_to preferred_forum
      end
    else
      #redirect_to preferred_forum
      @document = JSON.parse Setting.get('about') || '{}'
      render 'document', layout: 'layouts/closed'
	  end
  end

  def sign_in_modal
    authorize :static_pages
    @resource ||= User.new(r: request.referer, shortname: Shortname.new)
    respond_to do |format|
      format.js { render 'devise/sessions/new', layout: false, locals: {resource: @resource, resource_name: :user, devise_mapping: Devise.mappings[:user]} }
      format.html { render 'devise/sessions/new', layout: 'closed', locals: {resource: @resource, resource_name: :user, devise_mapping: Devise.mappings[:user]} }
    end
  end

  def about
    authorize :static_pages
    redirect_to info_path('about'), status: 302
  end

  def product
    authorize :static_pages
    redirect_to info_path('product'), status: 302
  end

  def developers
    authorize :static_pages
  end

  def how_argu_works
    authorize :static_pages
  end

  def team
    authorize :static_pages
    redirect_to info_path('team'), status: 302
  end

  def governments
    authorize :static_pages
    redirect_to info_path('governments'), status: 302
  end

  private
  def default_forum_path
    current_profile.present? ? preferred_forum : Forum.first_public
  end

end
