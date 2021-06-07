# frozen_string_literal: true

class CreateExport < CreateService
  def initialize(resource, attributes: {}, options: {})
    @resource = resource.build_child(Export, user_context: options[:user_context])
    super
  end
end
