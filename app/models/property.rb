# frozen_string_literal: true

require 'types/iri_type'

class Property < ApplicationRecord # rubocop:disable Metrics/ClassLength
  MAX_STR_LEN = 255
  TYPE_COLUMNS = %w[boolean string text datetime integer iri linked_edge_id].freeze
  TRANSLATABLE_COLUMNS = %w[string text].freeze

  belongs_to :edge, primary_key: :uuid
  belongs_to :linked_edge, class_name: 'Edge', primary_key: :uuid
  belongs_to :user, foreign_key: :integer # rubocop:disable Rails/InverseOf
  belongs_to :group, foreign_key: :integer # rubocop:disable Rails/InverseOf
  belongs_to :root, primary_key: :uuid, class_name: 'Edge'

  before_validation proc { |p| p.root_id ||= ActsAsTenant.current_tenant&.uuid || p.edge&.root_id }, on: :create
  validate :validate_page_root_id

  attribute :iri, IRIType.new
  after_save :cache_properties
  after_destroy :cache_properties

  default_scope lambda {
    ActsAsTenant.current_tenant ? where(root_id: ActsAsTenant.current_tenant.uuid) : all
  }

  delegate :cache_properties, to: :edge

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

  def validate_page_root_id
    return unless edge.is_a?(Page) && root_id && edge_id && root_id != edge_id

    errors.add(:root_id, 'Wrong root')
  end

  class << self
    def column_for_term(term)
      return :iri if term.is_a?(RDF::URI)

      raw = term.datatype.relativize(RDF::XSD).to_s.downcase.to_sym

      return :text if raw == :string && term.to_s.length >= MAX_STR_LEN
      return raw if TYPE_COLUMNS.include?(raw.to_s)

      :string
    end

    def from_statement(edge, statement)
      new(
        edge: edge,
        predicate: statement.predicate,
        column_for_term(statement.object) => statement.object.to_s
      )
    end

    def with_array_props
      @with_array_props ||=
        Arel::Nodes::As.new(
          array_props_table,
          arel_table.group(arel_table[:edge_id], arel_table[:predicate]).project(with_array_props_select)
        )
    end

    def with_json_props
      @with_json_props ||=
        Arel::Nodes::As.new(
          json_props_table,
          array_props_table.group(array_props_table[:edge_id]).project(with_json_props_select)
        )
    end

    private

    def array_props_table
      @array_props_table ||= Arel::Table.new(:array_props)
    end

    def array_props_to_json(column)
      Arel::Nodes::NamedFunction.new('to_json', [arel_table[column]])
    end

    def json_props_table
      @json_props_table ||= Arel::Table.new(:json_props)
    end

    def with_array_props_select
      [
        arel_table[:edge_id],
        arel_table[:predicate],
        Arel::Nodes::NamedFunction.new(
          'json_agg',
          [arel_table.coalesce(TYPE_COLUMNS.map(&method(:array_props_to_json)))]
        ).as('value')
      ]
    end

    def with_json_props_select
      [
        array_props_table[:edge_id],
        Arel::Nodes::NamedFunction.new(
          'json_object_agg',
          [array_props_table[:predicate], array_props_table[:value]]
        ).as('props')
      ]
    end
  end
end
