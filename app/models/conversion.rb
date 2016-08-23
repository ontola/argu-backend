# frozen_string_literal: true
class Conversion
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveRecord::AttributeAssignment

  validates :edge, presence: true
  validates :klass, presence: true

  attr_accessor :edge, :klass

  def initialize(edge: nil, klass: nil)
    @edge = edge
    @klass = klass
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
    edge.owner.convert_to(klass)
  end
  alias save! save

  def to_key
    []
  end

  def to_model
    self
  end
end
