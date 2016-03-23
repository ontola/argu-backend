class UpdateGroupResponse < UpdateService
  include Wisper::Publisher

  def initialize(group_response, attributes = {}, options = {})
    @group_response = group_response
    super
  end

  def resource
    @group_response
  end

  private

  def set_object_attributes(obj)
    obj.forum ||= @group_response.forum
    obj.creator ||= @group_response.creator
  end
end