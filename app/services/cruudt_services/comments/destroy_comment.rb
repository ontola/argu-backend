# frozen_string_literal: true
class DestroyComment < DestroyService
  def initialize(comment, attributes: {}, options: {})
    super
  end

  private

  def service_action
    :destroy
  end

  def service_method
    :wipe
  end
end
