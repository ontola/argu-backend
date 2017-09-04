# frozen_string_literal: true

module StubbornCookie
  module KVMethods
    def stubborn_get(key)
      redis_value = stubborn_redis_get(key) if stubborn_identifier.present?
      permeate_key(key, redis_value)
    end

    def stubborn_redis_get(key)
      STORE_CLASS.get("#{MODEL_NAME}:#{stubborn_identifier}:#{key}")
    end

    def stubborn_set!(key, value)
      STORE_CLASS.set("#{MODEL_NAME}:#{stubborn_identifier}:#{key}", value) if stubborn_identifier.present?
      cookies.permanent[key] = value
    end

    def stubborn_set_from_params
      k_v = permit_set_params
      stubborn_set!(k_v[:key], k_v[:value])
    end
  end
end
