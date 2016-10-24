# frozen_string_literal: true
class CreateGrant < CreateService
  include Wisper::Publisher
  def initialize(parent, attributes: {}, options: {})
    @resource = Grant.new(edge: parent)
    super
  end

  attr_reader :resource

  private

  def object_attributes=
  end
end
