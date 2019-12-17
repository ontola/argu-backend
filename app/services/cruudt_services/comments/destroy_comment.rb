# frozen_string_literal: true

class DestroyComment < DestroyEdge
  private

  def service_action
    :destroy
  end

  def service_method
    :wipe
  end
end
