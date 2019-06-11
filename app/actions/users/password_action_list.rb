# frozen_string_literal: true

module Users
  class PasswordActionList < ApplicationActionList
    def create_description
      I18n.t('devise.passwords.new.helper')
    end

    def create_include_resource?
      true
    end

    def create_on_collection?
      false
    end

    def create_policy; end

    def create_url
      iri_from_template(:passwords_iri)
    end

    def create_label
      I18n.t('devise.passwords.new.header')
    end

    def update_include_resource?
      true
    end

    def update_label
      I18n.t("devise.passwords.#{resource.user.encrypted_password.present? ? :edit : :set}.header")
    end

    def update_iri_path
      expand_uri_template(:edit_iri, update_template_opts)
    end

    def update_template_opts
      {
        parent_iri: resource.iri_path,
        reset_password_token: resource.reset_password_token
      }
    end

    def update_url
      iri_from_template(:passwords_iri)
    end
  end
end
