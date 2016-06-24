
class CreateGroupResponse < PublishedCreateService
  include Wisper::Publisher

  def resource_klass
    GroupResponse
  end
end
