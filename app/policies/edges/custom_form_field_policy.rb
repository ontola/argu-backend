# frozen_string_literal: true

class CustomFormFieldPolicy < EdgePolicy
  permit_attributes %i[display_name description helper_text default_value datatype max_count max_count_prop min_count
                       min_count_prop max_inclusive max_inclusive_prop min_inclusive min_inclusive_prop max_length
                       max_length_prop min_length min_length_prop pattern sh_in sh_in_prop predicate form_field_type_id]
end
