# frozen_string_literal: true

class SurveySerializer < ContentEdgeSerializer
  enum :form_type, predicate: NS.argu[:formType]
end
