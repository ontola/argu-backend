class DestroyGroupResponse < DestroyService
  include Wisper::Publisher

  def initialize(group_response, options = {})
    @group_response = group_response
    super
  end

  def resource
    @group_response
  end
end