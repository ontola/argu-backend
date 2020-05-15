# frozen_string_literal: true

module Trashable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :trashed_at,
                predicate: NS::ARGU[:trashedAt],
                if: ->(obj, _) { obj.is_trashable? }
      delegate :is_trashable?, to: :object

      has_one :trash_activity, predicate: NS::ARGU[:trashActivity], if: ->(obj, _) { obj.trashed_at.present? }
      has_one :untrash_activity, predicate: NS::ARGU[:untrashActivity], if: method(:never)
    end

    def trashed?
      object.trashed_at.present?
    end
  end
end
