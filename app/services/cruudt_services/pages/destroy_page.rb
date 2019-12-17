# frozen_string_literal: true

class DestroyPage < DestroyEdge
  def commit
    ActsAsTenant.with_tenant(resource) { super }
  end
end
