# frozen_string_literal: true

module Users
  class UnlockForm < ApplicationForm
    fields %i[email]
  end
end
