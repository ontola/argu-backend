class UntrashArgument < UntrashService
  include Wisper::Publisher

  def initialize(argument, options = {})
    @argument = argument
    super
  end

  def resource
    @argument
  end
end
