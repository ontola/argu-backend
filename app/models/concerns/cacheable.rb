# frozen_string_literal: true

module Cacheable
  include DeltaHelper

  def cacheable?
    true
  end

  def invalidate_cache
    ActsAsTenant.with_tenant(try(:root) || ActsAsTenant.current_tenant) do
      Argu::Cache.invalidate(iri)
    end
  end
end
