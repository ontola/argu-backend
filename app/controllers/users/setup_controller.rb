# frozen_string_literal: true

module Users
  class SetupController < AuthorizedController
    skip_before_action :authorize_action
    before_action :redirect_to_root, if: :has_shortname?
    active_response :edit, :update

    private

    def ld_action(_action)
      authenticated_resource.action(:setup, user_context)
    end

    def edit_execute
      authenticated_resource.build_shortname if authenticated_resource.shortname.blank?
      true
    end

    def has_shortname?
      current_user.url.present?
    end

    def model_name
      :user
    end

    def redirect_to_root
      redirect_to root_path
    end

    def resource_by_id
      current_user
    end

    def shortname_from_params
      return if params[:user].blank?
      params[:user][:url] ||
        params[:user][:shortname_attributes].try(:[], :shortname)
    end

    def update_execute
      current_user.build_shortname shortname: shortname_from_params
      current_user.update_without_password(permit_params)
    end

    def update_success_location
      setup_path
    end

    class << self
      def controller_class
        User
      end
    end
  end
end
