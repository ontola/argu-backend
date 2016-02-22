class StaticPagesController < ApplicationController
  geocode_ip_address

  def home
    authorize :static_page
    if signed_in? || within_user_cap?
      if current_user && policy(current_user).staff? && current_user.profile.memberships.present?
        @activities = policy_scope(Activity).order(created_at: :desc).limit(10)
        render #stream: true
      else
        redirect_to (preferred_forum.presence || info_url('about'))
      end
    else
      redirect_to (preferred_forum.presence || info_url('about'))
      #@document = JSON.parse Setting.get('about') || '{}'
      #render 'document', layout: 'layouts/closed'
    end
  end

  def developers
    authorize :static_page
  end

  def dismiss_announcement
    authorize :static_page
    announcement = Announcement.find(params[:id])
    stubborn_hmset 'announcements', announcement.identifier => :hidden
  end

  def how_argu_works
    authorize :static_page
  end

  def modern
    authorize :static_page, :about?
    render text: "modern: #{browser.modern?}, chrome: #{browser.chrome?}, safari: #{browser.safari?}, mobile: #{browser.mobile?}, tablet: #{browser.tablet?}, ua: #{browser.ua}"
  end

  # Used for persistent redis-backed cookies
  def persist_cookie
    authorize :static_page
    respond_to do |format|
      if stubborn_set_from_params
        format.json { head 200 }
      else
        format.json { head 400 }
      end
    end
  end

  private

  def default_forum_path
    current_profile.present? ? preferred_forum : Forum.first_public
  end
end
