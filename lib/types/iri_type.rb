# frozen_string_literal: true

class IRIType < ActiveRecord::Type::Value
  def type
    :string
  end

  def cast(value)
    RDF::URI(value) if value.present?
  end

  def serialize(value)
    value.to_s
  end
end

module QuoteIRI
  def quote(value)
    return super unless value.is_a?(RDF::URI) || value.is_a?(URI)

    super(value.to_s)
  end

  def type_cast(value)
    return super unless value.is_a?(RDF::URI) || value.is_a?(URI)

    super(value.to_s)
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(QuoteIRI)
