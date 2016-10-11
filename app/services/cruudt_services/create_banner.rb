
# frozen_string_literal: true
class CreateBanner < CreateService
  include Wisper::Publisher

  def initialize(profile, attributes: {}, options: {})
    @banner = Banner.new(attributes)
    super
  end

  def resource
    @banner
  end
end
