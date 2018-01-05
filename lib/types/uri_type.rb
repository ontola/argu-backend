# frozen_string_literal: true

class URIType < ActiveRecord::Type::Value
  def type
    :string
  end

  def cast(value)
    RDF::URI(value)
  end

  def serialize(value)
    value.to_s
  end
end
