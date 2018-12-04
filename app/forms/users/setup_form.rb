# frozen_string_literal: true

module Users
  class SetupForm < RailsLD::Form
    fields %i[
      url
      first_name
      last_name
    ]
  end
end
