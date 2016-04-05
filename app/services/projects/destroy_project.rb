class DestroyProject < DestroyService
  include Wisper::Publisher

  def initialize(project, options = {})
    @project = project
    super
  end

  def resource
    @project
  end

  private

  def set_object_attributes(obj)
    # Following can be ignored in this interface; phases, stepups
  end
end
