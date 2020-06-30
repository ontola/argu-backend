# frozen_string_literal: true

class ScenarioPolicy < EdgePolicy
  permit_attributes %i[display_name description]
end
