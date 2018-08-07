# frozen_string_literal: true

class Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::AttributeMethods
  include ActiveRecord::AttributeAssignment
  include ApplicationModel
  include Iriable
  include Parentable

  parentable :edge

  enhance Createable
  enhance Actionable, only: %i[Model]

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

  def is_publishable?
    false
  end

  def iri(opts = {})
    conversions_iri(edge.canonical_iri(only_path: true), opts)
  end

  def nested_attributes_options?
    false
  end

  def new_record?
    true
  end

  def persisted?
    false
  end

  def save
    edge.convert_to(klass)
  end
  alias save! save

  def to_key
    []
  end

  def to_model
    self
  end
end
