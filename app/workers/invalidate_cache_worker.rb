# frozen_string_literal: true

class InvalidateCacheWorker
  include Sidekiq::Worker
  extend RDF::Serializers::HextupleSerializer

  def perform(version)
    current_version = version.split('.')[0..1].join('.')
    current_cache_version = Argu::Redis.get('argu.cache.version')

    return if current_cache_version >= current_version

    self.class.invalidate_all
    Argu::Redis.set('argu.cache.version', current_cache_version)
  end

  class << self
    def invalidate_all
      Argu::Redis.publish(ENV['CACHE_CHANNEL'], Oj.fast_generate(value_to_hex(*invalidate_all_delta)))
    end

    def invalidate_all_delta
      [
        NS::SP[:Variable],
        NS::SP[:Variable],
        NS::SP[:Variable],
        NS::ONTOLA["invalidate?graph=#{CGI.escape(NS::SP[:Variable])}"]
      ]
    end
  end
end
