# frozen_string_literal: true

module Request
  class TrashRequestForm < ApplicationForm
    fields %i[
      trash_activity
    ]
  end
end
