# Service for updating groups.
class UpdateGroup < UpdateService
  include Wisper::Publisher

  def initialize(group, attributes: {}, options: {})
    @group = group
    super
  end

  def resource
    @group
  end
end
