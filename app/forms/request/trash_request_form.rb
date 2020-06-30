# frozen_string_literal: true

module Request
  class TrashRequestForm < ApplicationForm
    has_one :trash_activity, path: NS::ARGU[:trashActivity]
  end
end
