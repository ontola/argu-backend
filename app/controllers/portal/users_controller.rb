# frozen_string_literal: true

module Portal
  class UsersController < PortalBaseController
    include Common::Setup
    include Common::Destroy

    private

    def authenticated_resource
      @authenticated_resource ||= User.find_via_shortname(params[:id])
    end

    def execute_destroy
      authorize authenticated_resource, :destroy?

      ApplicationRecord.transaction do
        authenticated_resource.edges.destroy_all if params.require(:user)['destroy_content'].to_s == 'true'
        authenticated_resource.destroy
      end
    end

    def redirect_model_success(_resource)
      root_path
    end
  end
end
