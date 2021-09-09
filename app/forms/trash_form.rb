# frozen_string_literal: true

class TrashForm < ApplicationForm
  self.abstract_form = true

  has_one :trash_activity,
          form: ActivityForm,
          path: NS.argu[:trashActivity],
          min_count: 1
end
