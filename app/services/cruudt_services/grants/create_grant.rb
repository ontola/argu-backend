# frozen_string_literal: true
class CreateGrant < CreateService
  def initialize(parent, attributes: {}, options: {})
    @resource = Grant.new
    super
  end

  private

  def object_attributes=
  end
end
