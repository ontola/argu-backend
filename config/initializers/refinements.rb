# frozen_string_literal: true

def log(msg = '')
  Rails.logger.info(msg) if Rails.env.development?
end
