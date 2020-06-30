# frozen_string_literal: true

class IncidentPolicy < EdgePolicy
  permit_attributes %i[display_name description]
end
