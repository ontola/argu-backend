# frozen_string_literal: true
class UntrashArgument < UntrashService
  include Wisper::Publisher

  def initialize(argument, attributes: {}, options: {})
    @argument = argument
    super
  end

  def resource
    @argument
  end
end
