# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins do |source, _env|
      source.presence || '*'
    end

    resource '/.well-known/*', headers: :any, methods: %i[get]
    resource '/oauth/*', headers: :any, methods: %i[get post put patch delete options head], credentials: true
  end
end
