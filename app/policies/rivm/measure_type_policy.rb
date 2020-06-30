# frozen_string_literal: true

class MeasureTypePolicy < EdgePolicy
  permit_attributes %i[display_name description example_of_id category_id]
  permit_array_attributes %i[risks_id]
end
