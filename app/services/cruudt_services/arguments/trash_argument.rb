class TrashArgument < TrashService
  include Wisper::Publisher

  def initialize(argument, attributes: {}, options: {})
    @argument = argument
    super
  end

  def resource
    @argument
  end
end
