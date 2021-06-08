# frozen_string_literal: true

class SetupPolicy < RestrictivePolicy
  permit_attributes %i[display_name url]
end
