# frozen_string_literal: true

module Users
  class FollowsController < ParentableController
    active_response :destroy

    private

    def active_response_success_message
      return super unless action_name == 'destroy'
      I18n.t(:type_destroy_success, type: I18n.t('notifications.type'))
    end

    def authorize_action
      return super unless action_name == 'destroy'
      authorize parent_resource!, :update?
    end

    def destroy_execute
      parent_resource.follows.update_all(follow_type: :never) # rubocop:disable Rails/SkipsModelValidations
    end

    def destroy_success_options
      {
        location: destroy_success_location,
        notice: active_response_success_message
      }
    end

    def redirect_location
      parent_resource.iri
    end
  end
end
