# frozen_string_literal: true

module Users
  class SetupForm < ApplicationForm
    extend UsersHelper

    fields [
      {url: {default_value: ->(resource) { resource.form.target.url || suggested_shortname(resource.form.target) }}},
      :first_name,
      :last_name
    ]
  end
end
