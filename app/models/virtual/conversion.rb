# frozen_string_literal: true

class Conversion < VirtualResource
  include Parentable

  parentable :edge

  enhance LinkedRails::Enhancements::Creatable

  validates :edge, presence: true
  validates :klass_iri,
            presence: true,
            inclusion: {in: ->(r) { r.convertible_classes }}

  attr_accessor :edge, :klass_iri

  def convertible_classes
    edge.convertible_classes.keys.map { |c| c.to_s.classify.constantize.iri }
  end

  def edgeable_record
    @edgeable_record ||= edge
  end

  def initialize(edge: nil, klass_iri: nil) # rubocop:disable Lint/MissingSuper
    @edge = edge
    @klass_iri = klass_iri
  end

  def klass
    ApplicationRecord.descendants.detect do |klass|
      klass.iri.is_a?(Array) ? klass.iri.include?(klass_iri) : klass.iri == klass_iri
    end
  end

  def save
    edge.convert_to(klass)
  end
  alias save! save

  class << self
    def attributes_for_new(opts)
      {
        edge: opts[:parent]
      }
    end

    def route_key
      :conversion
    end
  end
end
