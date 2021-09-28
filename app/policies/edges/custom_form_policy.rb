# frozen_string_literal: true

class CustomFormPolicy < EdgePolicy
  permit_attributes %i[display_name]
end
