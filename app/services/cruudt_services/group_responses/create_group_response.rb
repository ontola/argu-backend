
class CreateGroupResponse < PublishedCreateService
  include Wisper::Publisher

  def initialize(group_response, attributes = {}, options = {})
    @group_response = group_response
    super
  end

  def resource
    @group_response
  end
end
