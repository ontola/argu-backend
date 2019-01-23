# frozen_string_literal: true

class DestroyPage < EdgeableDestroyService
  def commit
    ActsAsTenant.without_tenant { super }
  end
end
