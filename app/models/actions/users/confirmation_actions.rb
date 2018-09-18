# frozen_string_literal: true

module Actions
  module Users
    class ConfirmationActions < Base
      def create_on_collection?
        false
      end

      def create_policy; end

      def create_url(_resource)
        RDF::DynamicURI(expand_uri_template(:confirmations_iri, with_hostname: true))
      end

      def new_label
        I18n.t('devise.confirmations.edit.header')
      end
    end
  end
end
