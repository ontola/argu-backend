# frozen_string_literal: true

class SurveyPolicy < EdgePolicy
  def permitted_attribute_names
    super + %i[external_iri display_name description]
  end
end
