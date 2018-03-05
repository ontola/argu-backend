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

  def about
    authorize :static_page
    render('landing')
  end

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
    if current_user.is_staff?
      render # stream: true
    else
      current_user.guest? ? about : redirect_to(preferred_forum)
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
      format.html { redirect_back(fallback_location: root_path) }
      format.js do
        render 'announcements/dismissals/create',
               locals: {announcement: announcement}
      end
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

  def not_found
    handle_error(ActionController::RoutingError.new('Route not found'))
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

  def token
    @token = params[:token] && params[:token].length <= 24 ? params[:token] : ''
    render :token
  end

  private

  def default_forum_path
    preferred_forum
  end

  def tree_root_id
    return super unless action_name == 'home'
    GrantTree::ANY_ROOT
  end
end
