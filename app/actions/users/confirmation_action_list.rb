# frozen_string_literal: true

module Users
  class ConfirmationActionList < ApplicationActionList
    def create_on_collection?
      false
    end

    def create_policy; end

    def create_url
      iri_from_template(:confirmations_iri)
    end

    def create_label
      I18n.t('devise.confirmations.edit.header')
    end
  end
end
