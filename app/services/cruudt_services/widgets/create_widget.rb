# frozen_string_literal: true

class CreateWidget < CreateService
  def initialize(parent, attributes: {}, options: {})
    @resource = Widget.new(owner: parent)
    super
  end
end
