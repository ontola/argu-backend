# frozen_string_literal: true

class CustomFormFieldPolicy < EdgePolicy
  permit_attributes %i[display_name description helper_text default_value datatype max_count max_count_prop min_count
                       min_count_prop max_inclusive max_inclusive_prop min_inclusive min_inclusive_prop max_length
                       max_length_prop min_length min_length_prop pattern predicate
                       max_inclusive_label min_inclusive_label required]
  permit_attributes %i[form_field_type_id], has_values: {swipe_tool?: false}
  permit_nested_attributes %i[options_vocab]
end
