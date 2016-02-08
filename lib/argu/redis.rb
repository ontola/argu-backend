
# Our own wrapper for redis, to make stuff like error handling and host initialisation easier.
module Argu
  class Redis

    # Argu configured redis instance, use this by default.
    def self.redis_instance(host = ENV['REDIS_HOST'], port = ENV['REDIS_PORT'])
      ::Redis.new(host: host, port: port)
    end

    def self.get(key, redis = self.redis_instance)
      redis.get(key)
    rescue ::Redis::CannotConnectError => e
      self.rescue_redis_connection_error(e)
    end

    def self.set(key, value, redis = self.redis_instance)
      redis.set(key, value)
    rescue ::Redis::CannotConnectError => e
      self.rescue_redis_connection_error(e)
    end

    def self.setex(key, timeout, value, redis = self.redis_instance)
      redis.setex(key, timeout, value)
    rescue ::Redis::CannotConnectError => e
      self.rescue_redis_connection_error(e)
    end

    # Delegate `::Redis::CannotConnectError` to this method.
    # It automatically logs and sends to bugsnag.
    def self.rescue_redis_connection_error(e)
      Rails.logger.error 'Redis not available'
      ::Bugsnag.notify(e, {
                            :severity => 'error',
                        })
      nil
    end
  end
end
