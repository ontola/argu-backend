# frozen_string_literal: true

class BannerForm < ApplicationForm
  field :description, datatype: NS.fhir[:markdown]
  field :audience
  field :dismiss_button
  field :expires_at

  footer do
    actor_selector
  end

  hidden do
    field :is_draft
  end
end
