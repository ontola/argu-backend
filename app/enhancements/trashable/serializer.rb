# frozen_string_literal: true

module Trashable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :trashed_at,
                predicate: NS::ARGU[:trashedAt],
                if: :is_trashable?
      delegate :is_trashable?, to: :object

      has_one :trash_activity, predicate: NS::ARGU[:trashActivity], if: :trashed?
      has_one :untrash_activity, predicate: NS::ARGU[:untrashActivity], if: :never
    end

    def trashed?
      object.trashed_at.present?
    end
  end
end
