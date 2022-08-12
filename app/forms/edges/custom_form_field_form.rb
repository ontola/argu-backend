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
  field :display_name
  field :description
  %i[TextInput TextAreaInput MarkdownInput NumberInput CheckboxInput CheckboxGroup RadioGroup SelectInput
     ToggleButtonGroup ColorInput DateInput DateTimeInput MoneyInput IconInput LocationInput SliderInput EmailInput
     PasswordInput MultipleEmailInput FileInput PostalRangeInput].each do |type|
    field :helper_text,
          if: has_type(type)
  end
  %i[CheckboxGroup RadioGroup SelectInput ToggleButtonGroup].each do |type|
    has_one :options_vocab,
            if: has_type(type),
            form: Vocabularies::OptionsVocabForm,
            min_count: 1
  end
  %i[EmailInput PasswordInput TextAreaInput MarkdownInput TextInput].each do |type|
    field :min_length, if: has_type(type)
    field :max_length, if: has_type(type)
  end
  field :min_inclusive, min_count: 1, if: has_type(:SliderInput)
  field :min_inclusive_label, if: has_type(:SliderInput)
  field :max_inclusive, min_count: 1, if: has_type(:SliderInput)
  field :max_inclusive_label, if: has_type(:SliderInput)
  field :min_inclusive, if: has_type(:NumberInput)
  field :max_inclusive, if: has_type(:NumberInput)
  field :required, input_field: LinkedRails::Form::Field::CheckboxInput
  %i[TextInput CheckboxGroup SelectInput ColorInput DateInput DateTimeInput MultipleEmailInput
     FileInput PostalRangeInput].each do |type|
    field :max_count,
          if: has_type(type)
  end
  has_one :default_cover_photo, if: has_type(:SwipeInput)

  hidden do
    has_one :options_vocab,
            min_count: 1
  end
end
