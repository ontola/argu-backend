# frozen_string_literal: true

module Users
  class SetupForm < FormsBase
    fields %i[
      url
      first_name
      last_name
    ]
  end
end
