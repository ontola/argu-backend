
module StubbornCookie
  ALLOWED_SET_KEYS = %w(hide_video banners)
  MODEL_NAME = 'user'
  STORE_CLASS = Argu::Redis
  include HashMethods, KVMethods

  def stubborn_get(key)
    redis_value = stubborn_redis_get(key) if stubborn_identifier.present?
    cookies.permanent[key] = redis_value if redis_value.present? && cookies.permanent[key].blank?
    redis_value || cookies.permanent[key]
  end

  def stubborn_redis_get(key)
    STORE_CLASS.get("#{MODEL_NAME}:#{stubborn_identifier}:#{key}")
  end

  def permeate_key(key, value = nil)
    if value.present? #&& cookies.permanent[key].blank?
      if cookies.permanent[key].present?
        if value.is_a?(Hash)
          json = JSON.parse(cookies.permanent[key])
          value.merge!(json) if json.present?
        end
      end
      cookies.permanent[key] = value.is_a?(Hash) ? value.to_json : value.to_s
    end
    value.presence || possible_json_from_cookie(key)
  end

  def permit_set_params
    p = params.require(MODEL_NAME).permit(:key, :value)
    {
        key: ALLOWED_SET_KEYS.select { |v| v.eql?(p[:key]) }.first,
        value: p[:value]
    }
  end

  def stubborn_identifier
    current_user && current_user.id
  end

  def stubborn_key(key)
    "#{MODEL_NAME}:#{stubborn_identifier}:#{key}"
  end

  def possible_json_from_cookie(key)
    JSON.parse(cookies.permanent[key])
  rescue JSON::ParserError, TypeError
    cookies.permanent[key]
  end
end
