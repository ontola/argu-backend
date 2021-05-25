# frozen_string_literal: true

class Conversion < VirtualResource
  include Parentable

  parentable :edge

  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Actionable, only: %i[Model]

  validates :edge, presence: true
  validates :klass,
            presence: true,
            inclusion: {in: ->(r) { r.edge.convertible_classes.keys.map { |c| c.to_s.classify.constantize.iri } }}

  attr_accessor :edge, :klass

  def edgeable_record
    @edgeable_record ||= edge
  end

  def initialize(edge: nil, klass: nil)
    @edge = edge
    @klass = klass
  end

  def identifier
    "conversion_#{edge.id}_#{klass}"
  end

  def iri_opts
    {parent_iri: split_iri_segments(edge&.iri_path)}
  end

  def save
    edge.convert_to(klass)
  end
  alias save! save

  class << self
    def attributes_for_new(opts)
      {
        edge: opts[:parent],
        klass: convertible_class_names(opts[:parent])&.first
      }
    end

    private

    def convertible_class_names(record)
      record.convertible_classes.keys.map(&:to_s) if record.is_convertible?
    end
  end
end
