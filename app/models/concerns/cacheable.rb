# frozen_string_literal: true

module Cacheable
  def write_to_cache(cache = Argu::Cache.new)
    cache.write(self, :rdf, :nq)
  end
end
