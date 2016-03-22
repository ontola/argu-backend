
class CreateActivity < CreateService
  include Wisper::Publisher

  def initialize(profile, attributes = {})
    @activity = profile.activities.new
    super
  end

  def resource
    @activity
  end
end
