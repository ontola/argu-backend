# frozen_string_literal: true

class VotesController < EdgeableController # rubocop:disable Metrics/ClassLength
  include UriTemplateHelper
  skip_before_action :check_if_registered, only: %i[index show create destroy]

  private

  def active_response_success_message
    return super unless action_name == 'create'
    I18n.t('votes.alerts.success')
  end

  def authorize_action
    return super unless action_name == 'create'
    method = authenticated_resource.persisted? ? :update? : :create?
    authorize authenticated_resource, method
  end

  def create_success_json
    render locals: {model: authenticated_resource.parent, vote: authenticated_resource},
           status: :created,
           location: authenticated_resource.iri_path
  end

  def create_failure_html
    redirect_to authenticated_resource.parent.voteable.iri_path,
                notice: t('votes.alerts.failed')
  end

  def create_success_html
    if params[:vote].try(:[], :r).present?
      redirect_to redirect_param
    else
      redirect_to authenticated_resource.parent.voteable.iri_path,
                  notice: t('votes.alerts.success')
    end
  end

  def create_success_js
    unless authenticated_resource.parent.is_a?(Argument)
      return respond_with_redirect(location: authenticated_resource.parent.voteable.iri)
    end
    render locals: {model: authenticated_resource.parent, vote: authenticated_resource}
  end

  def destroy_success_js
    render locals: {
      vote: authenticated_resource
    }
  end

  def execute_action # rubocop:disable Metrics/AbcSize
    return super unless action_name == 'create'
    return super unless unmodified?
    respond_to do |format|
      format.html do
        if params[:vote].try(:[], :r).present?
          redirect_to redirect_param
        else
          redirect_to create_service.resource.parent.voteable.iri_path,
                      notice: t('votes.alerts.not_modified')
        end
      end
      format.json do
        render status: 304,
               locals: {model: create_service.resource.parent.voteable, vote: create_service.resource}
      end
      format.json_api { head 304 }
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { head 304 }
      end
      format.js { render locals: {model: create_service.resource.parent, vote: create_service.resource} }
    end
  end

  def collection_includes(_member_includes = {})
    super.merge(default_filtered_collections: inc_shallow_collection)
  end

  def create_includes
    [:partOf, voteable: :actions]
  end

  def default_vote_event_id?
    params[:vote_event_id] == VoteEvent::DEFAULT_ID
  end

  def index_success_html
    skip_verify_policy_scoped(true)
    redirect_to parent_resource!.iri_path
  end

  def new_form_locals
    {
      resource: resource.parent,
      vote: resource
    }
  end

  def resource_by_id
    return super unless %w[show destroy].include?(params[:action]) && params[:id].nil?
    @_resource_by_id ||=
      Edge
        .where_owner('Vote', creator: current_profile, root_id: root_from_params&.uuid)
        .find_by(parent: parent_resource)
  end

  def show_success_html
    redirect_to authenticated_resource.voteable.iri_path
  end

  def for_param # rubocop:disable Metrics/AbcSize
    if params[:for].is_a?(String) && params[:for].present?
      # Still used for upvoting arguments
      warn '[DEPRECATED] Using direct params is deprecated, please use proper nesting instead.'
      param = params[:for]
    elsif params[:vote].is_a?(ActionController::Parameters)
      param = params[:vote][:for]
    end
    param.present? && param !~ /\D/ ? Vote.fors.key(param.to_i) : param
  end

  def parent_from_params(opts = params)
    return super unless default_vote_event_id?
    super(opts.except(:vote_event_id))&.default_vote_event if parent_resource_key(opts.except(:vote_event_id))
  end

  def linked_record_parent(opts = params)
    return super unless default_vote_event_id?
    super(opts.except(:vote_event_id))&.default_vote_event
  end

  def unmodified?
    create_service.resource.persisted? && !create_service.resource.for_changed?
  end

  def deserialize_params_options
    {keys: {side: :for}}
  end

  def permit_params
    return super if params[:vote].present?
    params.permit(:id)
  end

  def redirect_param
    params.require(:vote).permit(:r)[:r]
  end

  def redirect_location
    if authenticated_resource.persisted?
      authenticated_resource.iri_path
    else
      authenticated_resource.voteable.iri_path
    end
  end

  def after_login_location
    expand_uri_template(
      :new_vote,
      voteable_path: parent_resource!.iri_path.split('/').select(&:present?),
      confirm: true,
      r: params[:r],
      'vote%5Bfor%5D' => for_param
    )
  end

  def resource_new_params
    super.merge(
      for: for_param,
      primary: true
    )
  end

  def create_meta # rubocop:disable Metrics/AbcSize
    data = []
    if authenticated_resource.parent.is_a?(VoteEvent)
      if default_vote_event_id?
        replace_vote_event_meta(data)
      else
        parent_collection = index_collection.unfiltered
        meta_replace_collection_count(data, index_collection.unfiltered)
        parent_collection.default_filtered_collections.each do |filtered_collection|
          meta_replace_collection_count(data, filtered_collection)
        end
      end
      voteable = authenticated_resource.parent.parent
      action_delta(data, :remove, voteable, :update_opinion)
      action_delta(data, :add, voteable.comment_collection, :create_opinion, include_parent: true)
      opinion_delta(data, voteable)
    else
      data = super
    end
    action_delta(data, :remove, authenticated_resource.parent, :create_vote, include_favorite: true)
    data
  end

  def destroy_meta # rubocop:disable Metrics/AbcSize
    data = super
    data.push [
      authenticated_resource.parent_iri,
      NS::ARGU[:currentVote],
      authenticated_resource.iri,
      NS::ARGU[:remove]
    ]
    if authenticated_resource.parent.is_a?(Argument)
      data.push [
        authenticated_resource.parent_iri,
        NS::ARGU[:votesProCount],
        authenticated_resource.parent.reload.children_counts['votes_pro'].to_i,
        NS::ARGU[:replace]
      ]
    end
    action_delta(data, :remove, authenticated_resource.parent, :destroy_vote, include_favorite: true)
    action_delta(data, :add, authenticated_resource.parent, :create_vote, include_favorite: true)
    data
  end

  def opinion_delta(data, voteable)
    [
      voteable.action(user_context, :update_opinion),
      voteable.comment_collection.action(user_context, :create_opinion)
    ].each do |object|
      data << [
        object.iri,
        NS::SCHEMA[:result],
        "#{authenticated_resource.for.classify}Opinion".constantize.iri,
        NS::ARGU[:replace]
      ]
    end
  end

  def replace_vote_event_meta(data) # rubocop:disable Metrics/AbcSize
    iri =
      if parent_resource.parent.is_a?(LinkedRecord)
        RDF::DynamicURI(parent_resource.iri.to_s.gsub('/lr/', '/od/').split('/vote_events/')[0])
      else
        parent_resource.iri
      end
    data.push(
      [
        iri,
        NS::ARGU[:voteableVoteEvent],
        parent_resource.iri,
        NS::ARGU[:replace]
      ]
    )
  end
end
