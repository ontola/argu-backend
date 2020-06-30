# frozen_string_literal: true

class RiskPolicy < EdgePolicy
  permit_attributes %i[display_name description]
end
