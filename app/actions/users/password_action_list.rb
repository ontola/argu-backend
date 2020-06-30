# frozen_string_literal: true

module Users
  class PasswordActionList < ApplicationActionList
    has_action(
      :create,
      create_options.merge(
        collection: false,
        description: -> { I18n.t('devise.passwords.new.helper') },
        include_object: true,
        label: -> { I18n.t('devise.passwords.new.header') },
        policy: nil,
        object: nil,
        url: -> { iri_from_template(:passwords_iri) }
      )
    )

    has_action(
      :update,
      update_options.merge(
        include_object: true,
        label: -> { I18n.t("devise.passwords.#{resource.user.encrypted_password.present? ? :edit : :set}.header") },
        root_relative_iri: -> { expand_uri_template(:edit_iri, update_template_opts) },
        url: -> { iri_from_template(:passwords_iri) }
      )
    )

    def update_template_opts
      {
        parent_iri: split_iri_segments(resource.iri_path),
        reset_password_token: resource.reset_password_token
      }
    end
  end
end
