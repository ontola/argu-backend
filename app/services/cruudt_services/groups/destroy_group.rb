# frozen_string_literal: true
# Service for destroying groups.
class DestroyGroup < DestroyService
  include Wisper::Publisher

  def initialize(group, attributes: {}, options: {})
    @group = group
    super
  end

  def resource
    @group
  end
end
