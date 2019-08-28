# frozen_string_literal: true

module Portal
  class UsersController < PortalBaseController
    include LinkedRails::Enhancements::Destroyable::Controller

    private

    def requested_resource
      @requested_resource ||= User.find_via_shortname_or_id(params[:id])
    end

    def destroy_execute
      authorize requested_resource, :destroy?

      ActsAsTenant.without_tenant do
        ApplicationRecord.transaction do
          requested_resource.edges.destroy_all if params.require(:user)['destroy_content'].to_s == 'true'
          requested_resource.destroy
        end
      end
    end

    def destroy_success_location
      root_path
    end
  end
end
