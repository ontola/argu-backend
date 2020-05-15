# frozen_string_literal: true

class ThingSerializer < RecordSerializer
  statements :property_statements

  def self.property_statements(object, _params)
    object.property_statements
  end
end
