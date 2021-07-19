# frozen_string_literal: true

class SurveySerializer < ContentEdgeSerializer
  attribute :currency, predicate: NS.schema.priceCurrency
  enum :form_type, predicate: NS.argu[:formType]
end
