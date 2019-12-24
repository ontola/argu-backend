# frozen_string_literal: true

class ThingSerializer < RecordSerializer
  statements :property_statements

  delegate :type, to: :object

  def display_name; end
end
