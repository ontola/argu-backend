# frozen_string_literal: true

module Request
  class TrashRequestForm < ApplicationForm
    fields [
      {trash_activity: {path: NS::ARGU[:trashActivity]}}
    ]
  end
end
