# frozen_string_literal: true

class VotesController < EdgeableController # rubocop:disable Metrics/ClassLength
  include UriTemplateHelper
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

  def execute_action # rubocop:disable Metrics/MethodLength
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

  def create_success
    super
    broadcast_vote_counts
  end

  def iri_without_id
    current_vote_iri(parent_resource)
  end

  def requested_resource
    return super unless %w[show destroy].include?(params[:action]) && params[:id].nil?

    @requested_resource ||=
      Vote
        .where_with_redis(creator: current_profile, root_id: tree_root_id)
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

  def option_param
    option = collection_params[:filter].try(:[], NS::SCHEMA.option)&.first || params[:vote].try(:[], :option)

    option.present? && option !~ /\D/ ? Vote.options.key(option.to_i) : option
  end

  def unmodified?
    create_service.resource.persisted? && !create_service.resource.option_changed?
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
    params.require(:vote).permit(:redirect_url)[:redirect_url]
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
      redirect_url: params[:redirect_url],
      'vote%5Bfor%5D' => option_param,
      with_hostname: true
    )
  end

  def resource_new_params
    super.merge(
      option: option_param,
      primary: true
    )
  end

  def create_meta
    data = counter_cache_delta(authenticated_resource)
    if authenticated_resource.parent.is_a?(VoteEvent)
      vote_collections.each do |collection|
        meta_replace_collection_count(data, collection)
      end
    else
      data.concat(reset_vote_action_status(authenticated_resource.parent))
    end
    data << same_as_statement
    data
  end

  def destroy_meta
    data = super
    data.push(
      [current_vote_iri(authenticated_resource.parent), NS::SCHEMA.option, NS::ARGU[:abstain], delta_iri(:replace)]
    )
    if authenticated_resource.parent.is_a?(Argument)
      data.concat(reset_vote_action_status(authenticated_resource.parent))
    end
    data
  end

  def replace_vote_event_meta(data)
    iri = parent_resource.iri

    data.push(
      [
        iri,
        NS::ARGU[:voteableVoteEvent],
        parent_resource.iri,
        delta_iri(:replace)
      ]
    )
  end

  def reset_vote_action_status(argument)
    %i[create_vote destroy_vote].map do |tag|
      action = argument.action(tag, user_context)
      [action.iri, NS::SCHEMA[:actionStatus], action.action_status, delta_iri(:replace)]
    end
  end

  def vote_collections
    unfiltered = index_collection.unfiltered
    [unfiltered] + %i[no yes other].map { |side| unfiltered.new_child(filter: {option: [side]}) }
  end
end