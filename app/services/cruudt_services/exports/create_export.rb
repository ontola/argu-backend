# frozen_string_literal: true

class CreateExport < CreateService
  def initialize(resource, attributes: {}, options: {})
    @resource = resource.build_child(Export)
    super
  end
end
