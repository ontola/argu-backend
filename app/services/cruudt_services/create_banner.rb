
class CreateBanner < CreateService
  include Wisper::Publisher

  def initialize(profile, attributes = {})
    @banner = Banner.new(attributes)
    super
  end

  def resource
    @banner
  end
end
