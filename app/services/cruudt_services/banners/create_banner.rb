# frozen_string_literal: true

class CreateBanner < CreateService
  def initialize(profile, attributes: {}, options: {})
    @resource = Banner.new(attributes)
    super
  end
end
