# frozen_string_literal: true

module Users
  class ConfirmationForm < ApplicationForm
    fields %i[email]
  end
end
