# frozen_string_literal: true

module Users
  class OtpSecretsController < LinkedRails::Auth::OtpSecretsController
    private

    def authenticated_resource
      current_resource
    end

    def same_as_statement
      RDF::Statement.new(
        LinkedRails.iri(path: '/u/otp_secrets/delete'),
        RDF::OWL.sameAs,
        LinkedRails.iri(path: "#{current_resource.root_relative_iri}/delete")
      )
    end
  end
end
