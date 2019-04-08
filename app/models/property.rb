# frozen_string_literal: true

class Property < ApplicationRecord
  belongs_to :edge, primary_key: :uuid
  belongs_to :linked_edge, class_name: 'Edge', primary_key: :uuid
  belongs_to :user, foreign_key: :integer
  belongs_to :group, foreign_key: :integer
  validate :valid_iri

  def raw_value
    attributes[type_column.to_s]
  end

  def type
    options[:type]
  end

  def value
    options[:enum] ? options[:enum].key(raw_value)&.to_s : raw_value
  end

  def value=(value)
    send("#{type_column}=", parse_value(value))
  end

  private

  def options
    @options ||= edge.class.property_options(predicate: predicate)
  end

  def parse_value(value)
    options[:enum] && options[:enum][value.try(:to_sym)] || value
  end

  def valid_iri
    return true unless type == :iri && value.present?

    errors.add(:string, "Invalid iri for #{options[:name]}") unless RDF::URI(value).valid?
  end

  def type_column
    type == :iri ? :string : type
  end
end
