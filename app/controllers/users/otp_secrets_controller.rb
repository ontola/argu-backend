# frozen_string_literal: true

module Users
  class OtpSecretsController < LinkedRails::Auth::OtpSecretsController
    skip_before_action :check_if_registered

    private

    def authenticated_resource
      current_resource
    end

    def resource_new_params
      {}
    end

    def same_as_statement
      RDF::Statement.new(
        LinkedRails.iri(path: '/u/otp_secrets/delete'),
        RDF::OWL.sameAs,
        LinkedRails.iri(path: "#{current_resource.iri_path}/delete")
      )
    end
  end
end
