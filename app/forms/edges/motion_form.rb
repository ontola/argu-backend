# frozen_string_literal: true

class MotionForm < ApplicationForm
  visibility_text

  class << self
    def location_required
      @location_required ||= [
        LinkedRails::SHACL::PropertyShape.new(
          path: [NS.schema.isPartOf, NS.argu[:requireLocation]],
          has_value: true
        )
      ]
    end
  end

  field :display_name
  field :description, datatype: NS.fhir[:markdown]
  has_one :default_cover_photo
  has_many :attachments
  has_one :placement, min_count: 1, if: location_required
  has_one :placement, unless: location_required

  group :advanced, label: -> { I18n.t('forms.advanced') } do
    field :mark_as_important, description: -> { mark_as_important_label }
    field :pinned
    field :options_vocab_id, min_count: 1, sh_in: -> { Vocabulary.root_collection.iri }
    field :expires_at
  end

  footer do
    actor_selector
  end

  hidden do
    field :is_draft
  end
end
