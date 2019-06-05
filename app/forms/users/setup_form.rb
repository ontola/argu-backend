# frozen_string_literal: true

module Users
  class SetupForm < ApplicationForm
    include UsersHelper

    fields [
      {url: {default_value: -> { target.url || suggested_shortname(target) }}},
      :first_name,
      :last_name
    ]
  end
end
