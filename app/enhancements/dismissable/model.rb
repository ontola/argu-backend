# frozen_string_literal: true

module Dismissable
  module Model
    extend ActiveSupport::Concern

    included do
      attribute :dismiss_action
      has_many :banner_dismissals
      with_collection :banner_dismissals
    end

    def dismiss_button=(_val)
      super
      dismiss_action_will_change!
    end

    def dismiss_action
      @dismiss_action ||= banner_dismissal_collection.action(:create).iri if dismiss_button.present?
    end
  end
end
