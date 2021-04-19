# frozen_string_literal: true

class MeasureForm < ApplicationForm
  field :display_name
  field :description, datatype: NS::FHIR[:markdown]
  field :second_opinion
  field :second_opinion_by, min_count: 1
  term_field :phase_ids, :fases, max_count: 999
  term_field :category_ids, :categorieen, max_count: 999
  has_one :custom_placement
  has_many :attachments
  field :attachment_published_at, min_count: 1
  field :measure_owner, min_count: 1
  field :contact_info
  field :more_info
  field :comments_allowed

  hidden do
    field :is_draft
  end
end
