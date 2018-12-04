# frozen_string_literal: true

module Request
  class TrashRequestForm < RailsLD::Form
    fields %i[
      trash_activity
    ]
  end
end
