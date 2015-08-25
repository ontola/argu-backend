class StaticPagesController < ApplicationController
  geocode_ip_address

  def home
    authorize :static_page
  	if signed_in? || within_user_cap?
      if current_user && policy(current_user).staff?
        @activities = policy_scope(Activity).order(created_at: :desc).limit(10)
        render #stream: true
      else
        redirect_to preferred_forum || info_url('about')
      end
    else
      #redirect_to preferred_forum
      #@document = JSON.parse Setting.get('about') || '{}'
      #render 'document', layout: 'layouts/closed'
	  end
  end

  def developers
    authorize :static_page
  end

  def how_argu_works
    authorize :static_page
  end

  def modern
    authorize :static_page, :about?
    render text: "modern: #{browser.modern?}, chrome: #{browser.chrome?}, safari: #{browser.safari?}, mobile: #{browser.mobile?}, tablet: #{browser.tablet?}, ua: #{browser.ua}"
  end

  private
  def default_forum_path
    current_profile.present? ? preferred_forum : Forum.first_public
  end

end
