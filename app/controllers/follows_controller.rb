# frozen_string_literal: true

class FollowsController < AuthorizedController
  PERMITTED_CLASSES = %w[Forum Question Motion Argument Comment Project BlogPost].freeze

  private

  def create_handler_success(_resource)
    send_event category: 'follows',
               action: permit_params[:follow_type],
               label: followable.model_name.collection
    super
  end

  def create_respond_blocks_failure(_resource, format)
    format.json { head 304 }
  end

  def create_respond_blocks_success(_resource, format)
    format.html { redirect_back(fallback_location: root_path, notification: t('followed')) }
    format.js { head 201 }
    format.json { head 201 }
  end

  def destroy_handler_success(_resource)
    send_event category: 'follows',
               action: permit_params[:follow_type],
               label: followable.model_name.collection
    super
  end

  def destroy_respond_blocks_failure(_resource, format)
    format.json { head 400 }
  end

  def destroy_respond_blocks_success(_resource, format)
    format.html { redirect_back(fallback_location: root_path, status: 303, notification: t('unfollowed')) }
    format.json { head 204 }
  end

  def execute_destroy
    authenticated_resource.destroy
  end

  def authenticated_resource!
    return super unless %w[create destroy].include?(action_name)
    @resource ||= current_user.follows.find_or_initialize_by(
      followable_id: followable.edge.id,
      followable_type: 'Edge'
    )
    @resource.follow_type = permit_params[:follow_type]
    @resource
  end

  def authorize_action
    return super unless %w[create destroy].include?(action_name)
    authorize followable, :follow?
  end

  def followable
    @followable ||= Edge.where(owner_type: PERMITTED_CLASSES).find(permit_params[:gid]).owner
  end

  def permit_params
    params.permit %i[follow_type gid]
  end
end
