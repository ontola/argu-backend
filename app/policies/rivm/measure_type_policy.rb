# frozen_string_literal: true

class MeasureTypePolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat [:display_name, :description, :example_of_id, :risks_id, risks_id: []]
    attributes
  end
end
