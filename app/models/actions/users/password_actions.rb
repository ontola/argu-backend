# frozen_string_literal: true

module Actions
  module Users
    class PasswordActions < Base
      def create_description
        I18n.t('devise.passwords.new.helper')
      end

      def create_on_collection?
        false
      end

      def create_policy; end

      def create_url(_resource)
        RDF::DynamicURI(expand_uri_template(:passwords_iri, with_hostname: true))
      end

      def new_label
        I18n.t('devise.passwords.new.header')
      end
    end
  end
end
