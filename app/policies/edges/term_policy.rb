# frozen_string_literal: true

class TermPolicy < EdgePolicy
  permit_attributes %i[display_name description exact_match]
end
