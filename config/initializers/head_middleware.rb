# frozen_string_literal: true

require_relative '../../lib/head_middleware'

Rails.application.config.middleware.use HeadMiddleware
