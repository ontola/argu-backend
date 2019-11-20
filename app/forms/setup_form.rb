# frozen_string_literal: true

class SetupForm < ApplicationForm
  include UsersHelper

  fields [
    {url: {default_value: -> { target.url || suggested_shortname(target.user) }}},
    :first_name,
    :last_name
  ]
end
