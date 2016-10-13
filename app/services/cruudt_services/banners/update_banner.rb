# frozen_string_literal: true
class UpdateBanner < UpdateService
  include Wisper::Publisher

  def initialize(banner, attributes: {}, options: {})
    @banner = banner
    super
  end

  def resource
    @banner
  end

  private

  def object_attributes=(obj)
    obj.forum ||= resource.forum
    obj.creator ||= resource.creator
  end
end
