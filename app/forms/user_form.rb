# frozen_string_literal: true

class UserForm < RailsLD::Form
  fields %i[
    first_name
    last_name
    hide_last_name
    time_zone
    home_placement
    birth_year
  ]
end
