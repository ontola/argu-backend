class TrashProject < TrashService
  include Wisper::Publisher

  def initialize(project, attributes: {}, options: {})
    @project = project
    super
  end

  def resource
    @project
  end

  private

  def object_attributes=(obj)
    # Following can be ignored in this interface; phases, stepups
  end
end
