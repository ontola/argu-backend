# frozen_string_literal: true
class DestroyMembership < DestroyService
  include Wisper::Publisher

  def initialize(membership, attributes: {}, options: {})
    @membership = membership
    super
  end

  def resource
    @membership
  end
end
