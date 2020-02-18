# frozen_string_literal: true

module Cacheable
  def write_to_cache(cache = Argu::Cache.new)
    ActsAsTenant.with_tenant(try(:root) || ActsAsTenant.current_tenant) do
      cache.write(self, :hex_adapter, :hndjson)
    end
  end
end
