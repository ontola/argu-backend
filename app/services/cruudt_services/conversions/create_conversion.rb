# frozen_string_literal: true
class CreateConversion < CreateService
  include Wisper::Publisher

  def initialize(conversion, attributes: {}, options: {})
    @conversion = conversion
    attributes[:klass] = attributes[:klass].classify.constantize if attributes[:klass].is_a?(String)
    super
  end

  def resource
    @conversion
  end
end
