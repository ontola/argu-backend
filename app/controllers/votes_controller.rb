# frozen_string_literal: true

class VotesController < EdgeableController # rubocop:disable Metrics/ClassLength
  include UriTemplateHelper
  skip_before_action :check_if_registered, only: %i[index show create destroy]
  skip_before_action :verify_setup

  private

  def abstain_vote
    return unless action_name == 'show'

    vote = Vote.new(
      parent: parent_resource,
      publisher: current_user,
      creator: current_profile
    )
    vote.instance_variable_set(:@iri, iri_without_id)
    vote
  end

  def active_response_success_message
    return super unless action_name == 'create'

    I18n.t('votes.alerts.success')
  end

  def authorize_action
    return super unless action_name == 'create'

    method = authenticated_resource.persisted? ? :update? : :create?
    authorize authenticated_resource, method
  end

  def broadcast_vote_counts
    return unless %w[create destroy].include?(action_name)

    RootChannel.broadcast_to(tree_root, hex_delta(counter_cache_delta(authenticated_resource)))
  end

  def execute_action
    return super unless action_name == 'create'
    return super unless unmodified?

    respond_to do |format|
      format.json do
        head 304
      end
      format.json_api { head 304 }
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { head 304 }
      end
    end
  end

  def collection_includes(_member_includes = {})
    super.merge(default_filtered_collections: Vote.inc_shallow_collection)
  end

  def create_success
    super
    broadcast_vote_counts
  end

  def default_vote_event_id?
    params[:vote_event_id] == VoteEvent::DEFAULT_ID
  end

  def iri_without_id
    current_vote_iri(parent_resource)
  end

  def resource_by_id
    return super unless %w[show destroy].include?(params[:action]) && params[:id].nil?

    @resource_by_id ||=
      Edge
        .where_owner('Vote', creator: current_profile, root_id: tree_root_id)
        .find_by(parent: parent_resource, primary: true) || abstain_vote
  end

  def same_as_statement
    [
      iri_without_id,
      NS::OWL.sameAs,
      current_resource.iri
    ]
  end

  def show_meta
    meta = super
    meta << same_as_statement if params[:id].nil?
    meta
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

  def parent_from_params(root = tree_root, opts = params_for_parent)
    return super unless default_vote_event_id?

    super(root, opts.except(:vote_event_id))&.default_vote_event if parent_resource_key(opts.except(:vote_event_id))
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

  def destroy_success
    super
    broadcast_vote_counts
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
      authenticated_resource.iri
    else
      authenticated_resource.voteable.iri
    end
  end

  def after_login_location
    expand_uri_template(
      :new_vote,
      voteable_path: parent_resource!.iri.path.split('/').select(&:present?),
      confirm: true,
      r: params[:r],
      'vote%5Bfor%5D' => for_param,
      with_hostname: true
    )
  end

  def resource_new_params
    super.merge(
      for: for_param,
      primary: true
    )
  end

  def create_meta # rubocop:disable Metrics/AbcSize
    data = counter_cache_delta(authenticated_resource)
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
      data.concat(reset_potential_and_favorite_delta(voteable))
      data.concat(reset_potential_and_favorite_delta(voteable.comment_collection))
      opinion_delta(data, voteable)
    else
      data.concat(reset_potential_and_favorite_delta(authenticated_resource.parent))
    end
    data << same_as_statement
    data
  end

  def destroy_meta
    data = super
    data.push(
      [current_vote_iri(authenticated_resource.parent), NS::SCHEMA.option, NS::ARGU[:abstain], delta_iri(:replace)]
    )
    data.concat(reset_potential_and_favorite_delta(authenticated_resource.parent))
    data
  end

  def opinion_delta(data, voteable) # rubocop:disable Metrics/AbcSize
    [
      voteable.action(:update_opinion, user_context),
      voteable.comment_collection.action(:create_opinion, user_context)
    ].compact.each do |object|
      data << [
        object.iri,
        NS::SCHEMA[:result],
        "#{authenticated_resource.for.classify}Opinion".constantize.iri,
        delta_iri(:replace)
      ]
    end
  end

  def replace_vote_event_meta(data) # rubocop:disable Metrics/AbcSize
    iri =
      if parent_resource.parent.is_a?(LinkedRecord)
        RDF::URI(parent_resource.iri.to_s.gsub('/lr/', '/od/').split('/vote_events/')[0])
      else
        parent_resource.iri
      end
    data.push(
      [
        iri,
        NS::ARGU[:voteableVoteEvent],
        parent_resource.iri,
        delta_iri(:replace)
      ]
    )
  end
end
