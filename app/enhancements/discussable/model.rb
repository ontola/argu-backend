# frozen_string_literal: true

module Discussable
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :discussions,
               -> { where(owner_type: Discussion.subclasses.map(&:to_s)) },
               class_name: 'Edge',
               foreign_key: :parent_id,
               inverse_of: :parent
      has_many :active_discussions,
               -> { active.where(owner_type: Discussion.subclasses.map(&:to_s)) },
               class_name: 'Edge',
               foreign_key: :parent_id,
               inverse_of: :parent

      with_collection :discussions,
                      default_sortings: [
                        {key: NS.argu[:pinnedAt], direction: :asc},
                        {key: NS.argu[:lastActivityAt], direction: :desc}
                      ]
    end
  end
end
