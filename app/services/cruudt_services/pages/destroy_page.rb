# frozen_string_literal: true

class DestroyPage < EdgeableDestroyService
  def commit
    ActsAsTenant.with_tenant(resource) { super }
  end
end
