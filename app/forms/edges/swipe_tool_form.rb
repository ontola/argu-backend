# frozen_string_literal: true

class SwipeToolForm < ApplicationForm
  field :display_name
  field :description, datatype: NS.fhir[:markdown]
  has_one :default_cover_photo
  has_one :placement

  group :advanced, label: -> { I18n.t('forms.advanced') } do
    field :pinned
    field :expires_at
  end

  footer do
    actor_selector
  end

  hidden do
    has_one :action_body
    field :is_draft
  end
end
