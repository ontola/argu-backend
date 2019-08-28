# frozen_string_literal: true

class Setting < ApplicationRecord
  class << self
    def set(key, value)
      Rails.logger.debug "Set #{key} to #{value}"

      find_or_create_by(key: key).update(value: value.to_s)
    end

    def get(key)
      find_by(key: key)&.value
    end
  end
end
