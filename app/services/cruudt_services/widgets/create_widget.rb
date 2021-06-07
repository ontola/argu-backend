# frozen_string_literal: true

class CreateWidget < CreateService
  def initialize(parent, attributes: {}, options: {})
    @resource = parent.build_child(Widget, user_context: options[:user_context])
    super
  end
end
