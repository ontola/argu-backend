# frozen_string_literal: true

module Motionable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :motions,
                      display: -> { parent.try(:default_motion_display)&.to_s&.sub('_display', '') },
                      default_sortings: -> { parent.class.default_motion_sorting_for(parent) },
                      joins: :default_vote_event

      property :default_options_vocab_id,
               :linked_edge_id,
               NS.argu[:defaultOptionsVocab],
               association: :default_options_vocab,
               association_class: 'Vocabulary'
    end

    module ClassMethods
      def default_motion_sorting_for(parent)
        sorting = default_motion_sorting_opts(parent)
        [
          {key: NS.argu[:pinnedAt], direction: :asc},
          sorting
        ]
      end

      private

      def default_motion_sorting_opts(parent) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
        return {key: NS.argu[:lastActivityAt], direction: :desc} unless parent.try(:default_motion_sorting)

        case parent.default_motion_sorting
        when 'popular'
          {key: NS.argu[:votesProCount], direction: :desc}
        when 'created_at'
          {key: NS.schema.dateCreated, direction: :desc}
        when 'updated_at'
          {key: NS.argu[:lastActivityAt], direction: :desc}
        when 'popular_asc'
          {key: NS.argu[:votesProCount], direction: :asc}
        when 'created_at_asc'
          {key: NS.schema.dateCreated, direction: :asc}
        when 'updated_at_asc'
          {key: NS.argu[:lastActivityAt], direction: :asc}
        end
      end
    end
  end
end
