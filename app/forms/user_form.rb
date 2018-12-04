# frozen_string_literal: true

class UserForm < RailsLD::Form
  fields %i[
    time_zone
    home_placement
    birth_year
  ]
end
