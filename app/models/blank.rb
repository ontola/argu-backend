# frozen_string_literal: true

class Blank
  def read_attribute_for_serialization(_key)
    {}
  end
end
