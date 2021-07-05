# frozen_string_literal: true

class SurveySerializer < ContentEdgeSerializer
  attribute :currency, predicate: NS.schema.priceCurrency
end
