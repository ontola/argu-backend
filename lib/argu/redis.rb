
module Argu
  class Redis

    def self.get(key, redis = ::Redis.new)
      begin
        redis.get(key)
      rescue ::Redis::CannotConnectError => e
        self.rescue_redis_connection_error(e)
      end
    end

    def self.set(key, value, redis = ::Redis.new)
      begin
        redis.set(key, value)
      rescue ::Redis::CannotConnectError => e
        self.rescue_redis_connection_error(e)
      end
    end

    def self.setex(key, timeout, value, redis = ::Redis.new)
      begin
        redis.setex(key, timeout, value)
      rescue ::Redis::CannotConnectError => e
        self.rescue_redis_connection_error(e)
      end
    end

    def self.rescue_redis_connection_error(e)
      Rails.logger.error 'Redis not available'
      ::Bugsnag.notify(e, {
                            :severity => 'error',
                        })
    end
  end
end
