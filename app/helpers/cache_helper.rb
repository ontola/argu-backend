# frozen_string_literal: true

module CacheHelper
  def set_cache_control_public
    response.headers['Cache-Control'] = 'public'
  end

  def valid_response?
    response.status == 200
  end
end
