# frozen_string_literal: true

class MeasureForm < ApplicationForm
  field :display_name
  field :description, datatype: NS.fhir[:markdown]
  field :second_opinion
  field :second_opinion_by, min_count: 1
  term_field :phase_ids,
             :fases,
             max_count: 999,
             sh_in_opts: {
               page_size: 99,
               sort: ['http%3A%2F%2Fschema.org%2Fname=asc']
             }
  term_field :category_ids,
             :categorieen,
             max_count: 999,
             sh_in_opts: {page_size: 99},
             input_field: LinkedRails::Form::Field::SelectInput
  has_one :custom_placement
  has_many :attachments
  field :attachment_published_at, min_count: 1
  field :measure_owner, min_count: 1
  field :contact_info
  field :more_info
  field :comments_allowed, input_field: LinkedRails::Form::Field::RadioGroup

  footer do
    actor_selector
  end

  hidden do
    field :is_draft
  end
end
