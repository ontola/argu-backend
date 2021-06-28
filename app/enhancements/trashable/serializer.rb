# frozen_string_literal: true

module Trashable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :trashed_at,
                predicate: NS.argu[:trashedAt],
                if: ->(obj, _) { obj.is_trashable? }

      has_one :trash_activity, predicate: NS.argu[:trashActivity], if: ->(obj, _) { obj.trashed_at.present? }
      has_one :untrash_activity, predicate: NS.argu[:untrashActivity], if: method(:never)
    end
  end
end
