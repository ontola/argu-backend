# frozen_string_literal: true

class SurveySerializer < ContentEdgeSerializer
  attribute :external_iri, predicate: NS::ARGU[:externalIRI]
end
