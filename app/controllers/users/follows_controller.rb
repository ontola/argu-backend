# frozen_string_literal: true

module Users
  class FollowsController < ParentableController
    active_response :destroy

    private

    def active_response_success_message
      return super unless action_name == 'destroy'
      t(:type_destroy_success, type: t('notifications.type'))
    end

    def authorize_action
      return super unless action_name == 'destroy'
      authorize parent_resource!, :update?
    end

    def destroy_execute
      parent_resource.follows.update_all(follow_type: :never)
    end

    def redirect_location
      parent_resource.iri_path
    end
  end
end
