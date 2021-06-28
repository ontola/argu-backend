# frozen_string_literal: true

class CommentForm < ApplicationForm
  field :description, datatype: NS.fhir[:markdown]

  footer do
    actor_selector
  end
end
