# frozen_string_literal: true

class SurveyPolicy < EdgePolicy
  permit_attributes %i[external_iri display_name description]
  permit_attributes %i[pinned], grant_sets: %i[moderator administrator staff]
end
