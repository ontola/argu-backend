# frozen_string_literal: true

class FollowsController < AuthorizedController
  PERMITTED_CLASSES = %w[Forum Question Motion Argument Comment BlogPost].freeze
  skip_before_action :check_if_registered, if: :unsubscribe?
  skip_before_action :authorize_action, if: :unsubscribe?

  private

  def create_handler_success
    send_event category: 'follows',
               action: permit_params[:follow_type],
               label: authenticated_resource.followable.model_name.collection
    super
  end

  def destroy_handler_success
    send_event category: 'follows',
               action: permit_params[:follow_type],
               label: authenticated_resource.followable.model_name.collection
    super
  end

  def destroy_failure_html
    return destroy_failure unless request.method == 'GET'
    render 'destroy', locals: {unsubscribed: false}
  end

  def destroy_success_html
    return destroy_success unless request.method == 'GET'
    render 'destroy', locals: {unsubscribed: true}
  end

  def destroy_execute
    @unsubscribed = !authenticated_resource.never? && authenticated_resource.never!
  end

  def index_collection_name; end

  def active_response_success_message
    t('notifications.changed_successfully')
  end

  def new_resource_from_params
    return @resource if instance_variable_defined?(:@resource)
    followable = Edge.where(owner_type: PERMITTED_CLASSES).find_by(uuid: permit_params[:gid])
    return @resource = nil if followable.nil?
    @resource = current_user.follows.find_or_initialize_by(
      followable_id: followable.uuid,
      followable_type: 'Edge'
    )
    @resource.follow_type = action_name == 'create' ? permit_params[:follow_type] || :reactions : :never
    @resource
  end

  def permit_params
    params.permit %i[follow_type gid]
  end

  def redirect_location
    authenticated_resource.followable.iri(only_path: true).to_s
  end

  def unsubscribe?
    action_name == 'destroy' && request.method == 'GET'
  end

  def tree_root_id
    @tree_root_id ||= authenticated_resource!&.followable&.root_id
  end
end
