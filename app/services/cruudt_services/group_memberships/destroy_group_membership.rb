class DestroyGroupMembership < DestroyService
  include Wisper::Publisher

  def initialize(membership, attributes: {}, options: {})
    @membership = membership
    super
  end

  def resource
    @membership
  end
end
