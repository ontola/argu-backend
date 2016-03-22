class UpdateArgument < UpdateService
  include Wisper::Publisher

  def initialize(project, attributes = {}, options = {})
    @argument = project
    super
  end

  def resource
    @argument
  end

  private

  def set_object_attributes(obj)
    obj.forum ||= @argument.forum
    obj.creator ||= @argument.creator
  end
end