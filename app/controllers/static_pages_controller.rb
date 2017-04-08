# frozen_string_literal: true
class StaticPagesController < ApplicationController
  include VotesHelper

  # geocode_ip_address
  VOCABULARIES = {
    hydra: 'http://www.w3.org/ns/hydra/core#',
    rdf: 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
    rdfs: 'http://www.w3.org/2000/01/rdf-schema#',
    schema: 'http://schema.org/',
    xsd: 'http://www.w3.org/2001/XMLSchema#'
  }.freeze

  C_MODELS = HashWithIndifferentAccess.new(
    question: Question,
    motion: Motion,
    argument: Argument,
    comment: Comment,
    user: User
  ).freeze

  def context
    skip_authorization
    model_context = C_MODELS[params['model']]
                      .contextualizer
                      .definitions_for_terms
                      .deep_transform_keys { |k| k.camelcase(:lower) }
    render json: {
      '@context': VOCABULARIES.merge(model_context)
    }
  end

  def home
    authorize :static_page
    if current_user.profile.has_role?(:staff)
      @activities = policy_scope(Activity.feed_for_favorites(current_user.favorites))
                      .order(created_at: :desc)
                      .limit(10)
      preload_user_votes(@activities.where(trackable_type: 'Motion').pluck(:trackable_id))
      render # stream: true
    else
      redirect_to(preferred_forum.presence || info_url('about'))
    end
  end

  def developers
    authorize :static_page
  end

  def dismiss_announcement
    authorize :static_page
    announcement = Announcement.find(params[:announcement_id])
    BannerDismissal.new(banner_class: Announcement,
                        banner: announcement)
    stubborn_hmset 'announcements', announcement.identifier => :hidden

    respond_to do |format|
      format.js do
        render 'announcements/dismissals/create',
               locals: {announcement: announcement}
      end
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def how_argu_works
    authorize :static_page
  end

  def modern
    authorize :static_page, :about?
    render text: "modern: #{browser.modern?}, chrome: #{browser.chrome?}, "\
                 "safari: #{browser.safari?}, mobile: #{browser.device.mobile?}, "\
                 "tablet: #{browser.device.tablet?}, ua: #{browser.ua}"
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

  def user_context
    @_uc ||= UserContext.new(
      current_user,
      current_profile,
      doorkeeper_scopes,
      false,
      session[:a_tokens]
    )
  end

  private

  def default_forum_path
    preferred_forum
  end
end
