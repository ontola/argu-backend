# frozen_string_literal: true

class StaticPagesController < AuthorizedController
  skip_before_action :authorize_action, only: :not_found
  skip_before_action :check_if_registered
  skip_after_action :verify_authorized, only: :not_found

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
    render('landing')
  end

  def context
    model_context = C_MODELS[params['model']]
                      .contextualizer
                      .definitions_for_terms
                      .deep_transform_keys { |k| k.camelcase(:lower) }
    render json: {
      '@context': VOCABULARIES.merge(model_context)
    }
  end

  def home
    active_response_block do
      respond_with_redirect location: current_user.is_staff? ? feeds_iri(nil) : preferred_forum.iri
    end
  end

  def developers; end

  def how_argu_works; end

  def not_found
    handle_error(ActionController::RoutingError.new('Route not found'))
  end

  # Used for persistent redis-backed cookies
  def persist_cookie
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

  def authorize_action
    authorize :static_page
  end

  def default_forum_path
    preferred_forum
  end
end
