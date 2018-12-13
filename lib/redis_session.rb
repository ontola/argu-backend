# frozen_string_literal: true

class RedisSession
  attr_accessor :authorization_token

  def initialize(authorization_token)
    self.authorization_token = authorization_token
  end

  def []=(key, value)
    values[key] = value
    Argu::Redis.set(redis_key, values.to_json)
  end
  delegate :[], to: :values

  def delete(key)
    value = values[key]
    Argu::Redis.set(redis_key, values.except!(key).to_json)
    value
  end

  private

  def redis_key
    @redis_key ||= "redis_session.#{authorization_token}"
  end

  def values
    @values ||= (stored_values || {}).with_indifferent_access
  end

  def stored_values
    values = Argu::Redis.get(redis_key)
    JSON.parse(values) if values
  end
end
