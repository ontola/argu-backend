# frozen_string_literal: true

class URIType < ActiveRecord::Type::Value
  def type
    :string
  end

  def cast(value)
    return RDF::URI(value) if Rails.env.production?
    RDF::URI(value&.to_s&.gsub('https://argu.co', Rails.application.config.origin))
  end

  def serialize(value)
    value.to_s
  end
end
