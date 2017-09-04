# frozen_string_literal: true

# Our own wrapper for redis, to make stuff like error handling and host initialisation easier.
module Argu
  class Redis
    # Argu configured redis instance, use this by default.
    def self.redis_instance(host = ENV['REDIS_ADDRESS'], port = ENV['REDIS_PORT'])
      ::Redis.new(host: host, port: port)
    end

    def self.exists(key, redis = redis_instance)
      redis.exists(key)
    rescue ::Redis::CannotConnectError => e
      rescue_redis_connection_error(e)
    end

    def self.expire(key, seconds, redis = redis_instance)
      redis.expire(key, seconds)
    rescue ::Redis::CannotConnectError => e
      rescue_redis_connection_error(e)
    end

    def self.delete(key, redis = redis_instance)
      redis.del(key)
    rescue ::Redis::CannotConnectError => e
      rescue_redis_connection_error(e)
    end

    def self.get(key, redis = redis_instance)
      redis.get(key)
    rescue ::Redis::CannotConnectError => e
      rescue_redis_connection_error(e)
    end

    def self.keys(pattern = '*', redis = redis_instance)
      redis.keys(pattern)
    rescue ::Redis::CannotConnectError => e
      rescue_redis_connection_error(e)
    end

    def self.persist(key, redis = redis_instance)
      redis.persist(key)
    rescue ::Redis::CannotConnectError => e
      rescue_redis_connection_error(e)
    end

    def self.rename(old_key, new_key, redis = redis_instance)
      redis.rename(old_key, new_key)
    rescue ::Redis::CannotConnectError => e
      rescue_redis_connection_error(e)
    end

    def self.set(key, value, redis = redis_instance)
      redis.set(key, value)
    rescue ::Redis::CannotConnectError => e
      rescue_redis_connection_error(e)
    end

    def self.setex(key, timeout, value, redis = redis_instance)
      redis.setex(key, timeout, value)
    rescue ::Redis::CannotConnectError => e
      rescue_redis_connection_error(e)
    end

    def self.hgetall(key, redis = ::Redis.new)
      redis.hgetall(key)
    rescue ::Redis::CannotConnectError => e
      rescue_redis_connection_error(e)
    end

    def self.hmset(key, values: {}, redis: ::Redis.new)
      redis.hmset(key, *values)
    rescue ::Redis::CannotConnectError => e
      rescue_redis_connection_error(e)
    end

    # Delegate `::Redis::CannotConnectError` to this method.
    # It automatically logs and sends to bugsnag.
    def self.rescue_redis_connection_error(e)
      Rails.logger.error 'Redis not available'
      ::Bugsnag.notify(e, severity: 'error')
      nil
    end
  end
end
