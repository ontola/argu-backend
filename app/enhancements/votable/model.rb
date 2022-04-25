# frozen_string_literal: true

module Votable
  module Model
    extend ActiveSupport::Concern

    included do
      with_collection :votes

      def default_vote_event
        self
      end

      def con_count
        children_count(option_record(NS.argu[:no])&.uuid)
      end

      def neutral_count
        children_count(option_record(NS.argu[:other])&.uuid)
      end

      def option_record(exact_match)
        vote_options.find_by(exact_match: exact_match)
      end

      def option_record!(exact_match)
        option_record(exact_match) || raise(ActiveRecord::RecordNotFound)
      end

      def pro_count
        children_count(option_record(NS.argu[:yes])&.uuid)
      end

      def vote_counts(graph = NS.ld[:supplant])
        sequence_iri = RDF::Node.new
        [[iri, NS.opengov[:count], sequence_iri, graph], [sequence_iri, RDF.type, RDF.Seq, graph]] +
          vote_options.flat_map.with_index { |option, index| vote_count(option, index, sequence_iri) }
      end

      def vote_options_iri
        options_vocab&.collection_iri(:terms, page: 1)
      end

      def voteable
        self
      end

      private

      def vote_count(option, index, sequence_iri)
        count_iri = RDF::Node.new
        [
          [sequence_iri, RDF[:"_#{index}"], count_iri],
          [count_iri, RDF.type, option.iri],
          [count_iri, RDF.value, children_count(option.uuid)]
        ]
      end

      def vote_options
        options_vocab&.active_terms || []
      end
    end
  end
end
