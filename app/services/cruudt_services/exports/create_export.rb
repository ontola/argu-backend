# frozen_string_literal: true

class CreateExport < CreateService
  def initialize(resource, attributes: {}, options: {})
    @resource = resource.exports.new
    super
  end
end
