# frozen_string_literal: true

endpoints_key = 'frontend.runtime.plain_endpoints'
frontend_db = 0

current_keys = Argu::Redis.lrange(endpoints_key, 0, -1, redis_opts: {db: frontend_db})
required_keys = %w[
  /(.*/)?d/(.*)
  /(.*/)?portal/(.*)
  /(.*/)?__better_errors/(.*)
]

(required_keys - current_keys).each do |key|
  Rails.logger.info "Registering #{key} as API endpoint"
  Argu::Redis.lpush(endpoints_key, key, redis_opts: {db: frontend_db})
end

Argu::Redis.set(
  [TenantMiddleware::REDIRECTS_KEY, Rails.application.config.origin].join('.'),
  "#{Rails.application.config.origin}/argu"
)
