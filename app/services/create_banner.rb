
class CreateBanner < ApplicationService
  include Wisper::Publisher

  def initialize(profile, attributes = {})
    @banner = Banner.new(attributes)
  end

  def resource
    @banner
  end

  def commit
    if @banner.valid? && @banner.save
      publish(:create_banner_successful, @banner)
    else
      publish(:create_banner_failed, @banner)
    end
  end

end
