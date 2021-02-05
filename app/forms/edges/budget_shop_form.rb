# frozen_string_literal: true

class BudgetShopForm < ApplicationForm
  visibility_text

  field :display_name
  field :description, datatype: NS::FHIR[:markdown]
  field :budget_max
  has_one :default_cover_photo
  has_many :attachments
  has_one :custom_placement

  group :advanced, label: -> { I18n.t('forms.advanced') } do
    field :mark_as_important, description: -> { mark_as_important_label }
    field :pinned
    field :expires_at
  end

  footer do
    actor_selector
  end

  hidden do
    field :is_draft
  end
end
