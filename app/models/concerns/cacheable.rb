# frozen_string_literal: true

module Cacheable
  include DeltaHelper

  def cacheable?
    true
  end

  def invalidate_cache(cache)
    ActsAsTenant.with_tenant(try(:root) || ActsAsTenant.current_tenant) do
      cache.write(invalidation_statements)
    end
  end

  def invalidation_statements
    [
      invalidate_resource(iri)
    ]
  end

  def invalidate_resource(iri)
    [iri, LinkedRails::Vocab::SP[:Variable], LinkedRails::Vocab::SP[:Variable], delta_iri(:invalidate)]
  end
end
