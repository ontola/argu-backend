# frozen_string_literal: true

module Users
  class OtpSecretsController < AuthorizedController
    include JWTHelper

    private

    def create_success
      active_response_block do
        respond_with_redirect(location: LinkedRails.iri.to_s, reload: true)
      end
    end

    def authenticated_resource
      return super if %w[delete destroy].include?(action_name) && params.key?(:id)

      @authenticated_resource ||=
        controller_class.find_or_create_by!(user_id: current_user.id || raise(ActiveRecord::RecordNotFound))
    end

    def delete_success_options
      super.merge(
        meta: [
          RDF::Statement.new(delete_iri('users/otp_secrets'), NS::OWL.sameAs, delete_iri(authenticated_resource))
        ]
      )
    end

    def destroy_success
      active_response_block do
        respond_with_redirect(location: LinkedRails.iri.to_s, reload: true)
      end
    end

    def permit_params
      return super unless action_name == 'create'

      super.merge(active: true)
    end
  end
end
