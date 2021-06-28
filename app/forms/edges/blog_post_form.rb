# frozen_string_literal: true

class BlogPostForm < ApplicationForm
  visibility_text

  field :display_name
  field :description, datatype: NS.fhir[:markdown]
  has_one :default_cover_photo
  has_many :attachments

  group :advanced, label: -> { I18n.t('forms.advanced') } do
    field :mark_as_important, description: -> { mark_as_important_label }
  end

  footer do
    actor_selector
  end

  hidden do
    field :is_draft
  end
end
