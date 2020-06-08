# frozen_string_literal: true

module Cacheable
  def cacheable?
    true
  end

  def write_to_cache(cache = Argu::Cache.new)
    return unless cacheable?

    ActsAsTenant.with_tenant(try(:root) || ActsAsTenant.current_tenant) do
      cache.write(self, :hndjson)
    end
  end
end
