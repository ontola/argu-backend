
module StubbornCookie
  ALLOWED_SET_KEYS = %w(hide_video)
  MODEL_NAME = 'user'
  STORE_CLASS = Argu::Redis

  def stubborn_get(key)
    redis_value = stubborn_redis_get(key) if stubborn_identifier.present?
    cookies.permanent[key] = redis_value if redis_value.present? && cookies.permanent[key].blank?
    redis_value || cookies.permanent[key]
  end

  def stubborn_redis_get(key)
    STORE_CLASS.get("#{MODEL_NAME}:#{stubborn_identifier}:#{key}")
  end

  def permit_set_params
    p = params.require(MODEL_NAME).permit(:key, :value)
    {
        key: ALLOWED_SET_KEYS.select { |v| v.eql?(p[:key]) }.first,
        value: p[:value]
    }
  end

  def stubborn_set_from_params
    k_v = permit_set_params
    stubborn_set!(k_v[:key], k_v[:value])
  end

  def stubborn_set!(key, value)
    STORE_CLASS.set("#{MODEL_NAME}:#{stubborn_identifier}:#{key}", value) if stubborn_identifier.present?
    cookies.permanent[key] = value
  end

  def stubborn_identifier
    current_user && current_user.id
  end
end
