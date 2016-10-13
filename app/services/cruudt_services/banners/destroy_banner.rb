# frozen_string_literal: true
class DestroyBanner < DestroyService
  include Wisper::Publisher

  def initialize(banner, attributes: {}, options: {})
    @banner = banner
    super
  end

  def resource
    @banner
  end
end
