
# frozen_string_literal: true
class CreateActivity < CreateService
  include Wisper::Publisher

  def initialize(activity, attributes: {}, options: {})
    @activity = activity
    super
  end

  def resource
    @activity
  end
end
