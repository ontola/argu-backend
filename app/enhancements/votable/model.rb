# frozen_string_literal: true

module Votable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :votes

      def action_triples
        super + vote_action_triples
      end

      private

      def vote_action_triples
        options = upvote_only? ? %i[yes] : %i[yes other no]
        options.map do |option|
          action = vote_collection.new_child(filter: {NS::SCHEMA[:option] => [option]}).action(:create)
          [iri, LinkedRails::Vocab::ONTOLA[:favoriteAction], action.iri]
        end
      end
    end
  end
end
