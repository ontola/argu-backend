# frozen_string_literal: true

module Trashable
  module Serializer
    extend ActiveSupport::Concern

    included do
      attribute :trashed_at,
                predicate: NS::ARGU[:trashedAt],
                if: :is_trashable?
      delegate :is_trashable?, to: :object
    end
  end
end
