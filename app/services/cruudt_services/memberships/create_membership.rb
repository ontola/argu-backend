# frozen_string_literal: true
class CreateMembership < EdgeableCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super
  end

  private

  def object_attributes=(obj)
  end
end
