
class CreateGroup < CreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    @group = resource_klass.new
    attributes[:forum] = parent.owner
    super
  end

  def resource
    @group
  end
end
