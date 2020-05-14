# frozen_string_literal: true

endpoints_key = 'frontend.runtime.plain_endpoints'

current_keys = Argu::Redis.lrange(endpoints_key, 0, -1)
required_keys = %w[
  /(.*/)?d/(.*)
  /(.*/)?portal/(.*)
]

(required_keys - current_keys).each do |key|
  Rails.logger.info "Registering #{key} as API endpoint"
  Argu::Redis.lpush(endpoints_key, key)
end
