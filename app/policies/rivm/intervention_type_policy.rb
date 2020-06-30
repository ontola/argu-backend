# frozen_string_literal: true

class InterventionTypePolicy < EdgePolicy
  permit_attributes %i[display_name description]
end
