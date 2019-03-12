# frozen_string_literal: true

module Users
  class NotificationsForm < ApplicationForm
    fields %i[
      reactions_email
      news_email
    ]
  end
end
