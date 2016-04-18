
class CreateGroup < CreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    @group = resource_klass.new
    attributes[:edge] = parent
    super
  end

  def resource
    @group
  end
end
