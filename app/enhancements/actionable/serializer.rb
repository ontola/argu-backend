# frozen_string_literal: true

module Actionable
  module Serializer
    extend ActiveSupport::Concern

    included do
      has_many :actions,
               key: :operation,
               unless: :system_scope?,
               predicate: NS::SCHEMA[:potentialAction],
               graph: NS::LL[:add]

      triples :action_methods

      def actions
        object.actions(scope) if scope.is_a?(UserContext)
      end

      def action_methods
        triples = []
        actions&.each { |action| triples.append(action_triples(action)) }
        triples
      end

      private

      def action_triples(action)
        action_triple(object, NS::ARGU["#{action.tag}_action".camelize(:lower)], action.iri, NS::LL[:add])
      end

      def action_triple(subject, predicate, iri, graph = nil)
        subject_iri = subject.iri
        subject_iri = RDF::URI(subject_iri.to_s.sub('/lr/', '/od/'))
        [subject_iri, predicate, iri, graph]
      end
    end
  end
end
