# frozen_string_literal: true

class VotesController < EdgeableController
  skip_before_action :verify_setup

  private

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
    data
  end

  def create_success
    super
    broadcast_vote_counts
  end

  def remove_same_as_delta
    [current_vote_iri(authenticated_resource.parent), NS::SCHEMA.option, NS::ARGU[:abstain], delta_iri(:replace)]
  end

  def destroy_success
    super
    broadcast_vote_counts
  end

  def execute_action
    return super unless action_name == 'create'
    return super unless unmodified?

    head 304
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

  def invalidate_trash_action
    [
      current_resource.action(:trash).iri,
      NS::SP[:Variable],
      NS::SP[:Variable],
      delta_iri(:invalidate)
    ]
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
