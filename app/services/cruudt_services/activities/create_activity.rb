
class CreateActivity < CreateService
  include Wisper::Publisher

  def initialize(activity, attributes = {})
    @activity = activity
    super
  end

  def resource
    @activity
  end
end
