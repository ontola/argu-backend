# frozen_string_literal: true

class SetupPolicy < RestrictivePolicy
  permit_attributes %i[first_name middle_name last_name url]
end
