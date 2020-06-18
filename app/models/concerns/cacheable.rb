# frozen_string_literal: true

module Cacheable
  include DeltaHelper

  def cacheable?
    true
  end

  def invalidate_cache(cache)
    ActsAsTenant.with_tenant(try(:root) || ActsAsTenant.current_tenant) do
      delta = [
        [iri, LinkedRails::Vocab::SP[:Variable], LinkedRails::Vocab::SP[:Variable], delta_iri(:invalidate)]
      ]
      cache.write(delta)
    end
  end
end
