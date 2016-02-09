module StubbornCookie
  module HashMethods

    def stubborn_hgetall(key)
      redis_value = stubborn_redis_hgetall(key).with_indifferent_access if stubborn_identifier.present?
      permeate_key(key, redis_value)
    end

    def stubborn_hmset(key, values = {})
      stubborn_redis_hmset(key, values)
      permeate_key(key, values)
    end

    def stubborn_redis_hgetall(key)
      STORE_CLASS.hgetall stubborn_key(key)
    end

    def stubborn_redis_hmset(key, values = {})
      STORE_CLASS.hmset(stubborn_key(key), values: values)
    end
  end
end
