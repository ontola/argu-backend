# frozen_string_literal: true

module Users
  class UnlockActionList < ApplicationActionList
    def create_description
      I18n.t('devise.unlocks.new.helper')
    end

    def create_on_collection?
      false
    end

    def create_policy; end

    def create_url
      iri_from_template(:user_unlock)
    end

    def create_label
      I18n.t('devise.unlocks.new.header')
    end

    def update_label
      I18n.t('devise.unlocks.unlocked')
    end

    def update_url
      iri_from_template(:user_unlock)
    end
  end
end
