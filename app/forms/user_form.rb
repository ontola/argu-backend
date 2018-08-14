# frozen_string_literal: true

class UserForm < FormsBase
  fields %i[
    language
    time_zone
    home_placement
    birth_year
  ]
end
