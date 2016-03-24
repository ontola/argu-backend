class UntrashProject < UntrashService
  include Wisper::Publisher

  def initialize(project, options = {})
    @project = project
    super
  end

  def resource
    @project
  end
end
