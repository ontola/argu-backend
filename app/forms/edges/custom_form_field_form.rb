# frozen_string_literal: true

class CustomFormFieldForm < ApplicationForm
  def self.has_type(*types)
    types.map do |type|
      LinkedRails::SHACL::PropertyShape.new(
        path: [NS.argu[:formFieldType], NS.skos.exactMatch],
        has_value: -> { NS.form[type] }
      )
    end
  end

  term_field :form_field_type_id,
             :formFields,
             min_count: 1,
             sh_in_opts: {page_size: 99}
  field :position
  field :display_name
  field :description
  field :helper_text
  %i[CheckboxGroup RadioGroup SelectInput ToggleButtonGroup].each do |type|
    field :sh_in,
          if: has_type(type),
          sh_in: -> { Vocabulary.root_collection.iri },
          min_count: 1
  end
  %i[EmailInput PasswordInput TextAreaInput MarkdownInput TextInput].each do |type|
    field :min_length, if: has_type(type)
    field :max_length, if: has_type(type)
  end
  field :min_inclusive, min_count: 1, if: has_type(:SliderInput)
  field :max_inclusive, min_count: 1, if: has_type(:SliderInput)
  field :min_inclusive, if: has_type(:NumberInput)
  field :max_inclusive, if: has_type(:NumberInput)
  field :min_count
  field :max_count

  group :advanced, label: -> { I18n.t('forms.advanced') } do
    field :predicate
  end
end
