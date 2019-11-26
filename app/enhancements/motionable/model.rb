# frozen_string_literal: true

module Motionable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :motions,
                      default_sortings: ->(parent) { default_motion_sorting_for(parent) },
                      joins: :default_vote_event
    end

    module ClassMethods
      def default_motion_sorting_for(parent)
        sorting = default_motion_sorting_opts(parent)
        [
          {key: NS::ARGU[:pinnedAt], direction: :asc},
          sorting
        ]
      end

      def default_motion_sorting_opts(parent) # rubocop:disable Metrics/CyclomaticComplexity
        return {key: NS::ARGU[:lastActivityAt], direction: :desc} unless parent.try(:default_motion_sorting)
        case parent.default_motion_sorting
        when 'popular'
          {key: NS::ARGU[:votesProCount], direction: :desc}
        when 'created_at'
          {key: NS::ARGU[:createdAt], direction: :desc}
        when 'updated_at'
          {key: NS::ARGU[:lastActivityAt], direction: :desc}
        when 'popular_asc'
          {key: NS::ARGU[:votesProCount], direction: :asc}
        when 'created_at_asc'
          {key: NS::ARGU[:createdAt], direction: :asc}
        when 'updated_at_asc'
          {key: NS::ARGU[:lastActivityAt], direction: :asc}
        end
      end

      def show_includes
        super + [
          motion_collection: inc_shallow_collection
        ]
      end
    end
  end
end
