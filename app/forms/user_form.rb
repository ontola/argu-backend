# frozen_string_literal: true

class UserForm < ApplicationForm
  fields %i[
    first_name
    last_name
    hide_last_name
    time_zone
    birth_year
  ]
end
