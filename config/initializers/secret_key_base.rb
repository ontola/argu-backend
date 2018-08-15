# frozen_string_literal: true

module Rails
  class Application
    def secret_key_base
      validate_secret_key_base(
        ENV['SECRET_KEY_BASE'] || credentials.secret_key_base || secrets.secret_key_base
      )
    end
  end
end
