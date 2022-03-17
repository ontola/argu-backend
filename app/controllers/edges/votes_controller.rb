# frozen_string_literal: true

class VotesController < EdgeableController
  skip_before_action :verify_setup

  has_singular_destroy_action
  has_singular_trash_action

  private

  def active_response_success_message
    case action_name
    when 'create'
      create_success_message
    when 'trash', 'destroy'
      I18n.t('votes.alerts.trashed')
    else
      super
    end
  end

  def allow_empty_params?
    true
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

  def create_success_message
    return I18n.t('votes.alerts.login_to_succeed') if current_user.guest?
    return I18n.t('votes.alerts.confirm_to_succeed') unless current_user.confirmed?

    I18n.t('votes.alerts.success')
  end

  def current_resource
    return super unless action_name == 'create' && current_user.guest?

    resource = super
    resource.singular_resource = true
    resource
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

  def invalidate_trash_action
    [
      current_resource.action(:trash).iri,
      NS.sp.Variable,
      NS.sp.Variable,
      delta_iri(:invalidate)
    ]
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

  def singular_added_delta(resource)
    [same_as_statement(resource.singular_iri, resource.iri)]
  end

  def singular_removed_delta(resource)
    [[current_vote_iri(resource.parent), NS.schema.option, NS.argu[:abstain], delta_iri(:replace)]]
  end

  def trash_meta
    destroy_meta
  end

  def unmodified?
    create_service.resource.persisted? && !create_service.resource.option_id_changed?
  end
end
