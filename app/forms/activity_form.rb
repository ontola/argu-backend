# frozen_string_literal: true

class ActivityForm < ApplicationForm
  fields %i[
    comment
    notify
  ]
end
