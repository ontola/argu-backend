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
    case action_name
    when 'create'
      I18n.t('votes.alerts.success')
    when 'trash'
      I18n.t('votes.alerts.trashed')
    else
      super
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

  def authorize_action
    return super unless action_name == 'create'

    method = authenticated_resource.persisted? ? :update? : :create?
    authorize authenticated_resource, method
  end

  def broadcast_vote_counts
    RootChannel.broadcast_to(tree_root, hex_delta(counter_cache_delta(authenticated_resource)))
  end

  def create_meta
    data = super
    data << invalidate_trash_action
    data << same_as_statement
    data
  end

  def create_success
    super
    broadcast_vote_counts
  end

  def destroy_meta
    data = super
    data.push(
      [current_vote_iri(authenticated_resource.parent), NS::SCHEMA.option, NS::ARGU[:abstain], delta_iri(:replace)]
    )
    data
  end

  def destroy_success
    super
    broadcast_vote_counts
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

  def iri_without_id
    current_vote_iri(parent_resource)
  end

  def option_param
    option = collection_params[:filter].try(:[], NS::SCHEMA.option)&.first || params[:vote].try(:[], :option)

    option.present? && option !~ /\D/ ? Vote.options.key(option.to_i) : option
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

  def requested_resource
    return super unless %w[show destroy bin trash].include?(params[:action]) && params[:id].nil?

    @requested_resource ||=
      Vote
        .where_with_redis(creator: current_profile, root_id: tree_root_id)
        .find_by(parent: parent_resource, primary: true) || abstain_vote
  end

  def resource_new_params
    super.merge(
      option: option_param,
      primary: true
    )
  end

  def invalidate_trash_action
    [
      current_resource.action(:trash).iri,
      NS::SP[:Variable],
      NS::SP[:Variable],
      delta_iri(:invalidate)
    ]
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

  def trash_success
    super
    broadcast_vote_counts
  end

  alias trash_meta destroy_meta

  def unmodified?
    create_service.resource.persisted? && !create_service.resource.option_changed?
  end
end
