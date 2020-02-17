# frozen_string_literal: true

module Users
  class SetupController < AuthorizedController
    skip_before_action :authorize_action
    skip_before_action :verify_setup
    before_action :redirect_to_root, if: :redirect_to_root?
    active_response :edit, :update

    private

    def edit_execute
      current_user.build_shortname if current_user.shortname.blank?
      true
    end

    def redirect_to_root
      redirect_to root_path
    end

    def redirect_to_root?
      current_user.guest? || has_shortname?
    end

    def resource_by_id
      @resource_by_id ||= Setup.new(user: current_user)
    end

    def update_execute
      current_user.build_shortname shortname: permit_params[:url]
      current_user.update_without_password(permit_params)
    end

    def update_success
      respond_with_resource(resource: current_actor)
    end

    def update_success_location
      setup_path
    end
  end
end
