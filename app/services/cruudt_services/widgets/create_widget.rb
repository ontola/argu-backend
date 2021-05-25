# frozen_string_literal: true

class CreateWidget < CreateService
  def initialize(parent, attributes: {}, options: {})
    @resource = parent.build_child(Widget)
    super
  end
end
