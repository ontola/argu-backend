# frozen_string_literal: true

require 'types/iri_type'

class Property < ApplicationRecord
  TYPE_COLUMNS = %w[boolean string text datetime integer iri linked_edge_id].freeze
  TRANSLATABLE_COLUMNS = %w[string text].freeze

  belongs_to :edge, primary_key: :uuid
  belongs_to :linked_edge, class_name: 'Edge', primary_key: :uuid
  belongs_to :user, foreign_key: :integer
  belongs_to :group, foreign_key: :integer

  attribute :iri, IRIType.new

  def raw_value
    attributes[type.to_s]
  end

  def type
    options[:type] || TYPE_COLUMNS.detect { |column| attributes[column].present? }
  end

  def value
    if options[:enum]
      options[:enum].key(raw_value)&.to_s
    elsif TRANSLATABLE_COLUMNS.include?(type)
      RDF::Literal(raw_value, language: language)
    else
      raw_value
    end
  end

  def value=(value)
    send("#{type}=", parse_value(value))
  end

  private

  def options
    @options ||= edge.class.property_options(predicate: predicate) || {}
  end

  def parse_value(value)
    options[:enum] && options[:enum][value.try(:to_sym)] || value
  end
end
