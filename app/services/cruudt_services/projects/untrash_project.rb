# frozen_string_literal: true
class UntrashProject < UntrashService
  include Wisper::Publisher

  def initialize(project, attributes: {}, options: {})
    @project = project
    super
  end

  def resource
    @project
  end
end
