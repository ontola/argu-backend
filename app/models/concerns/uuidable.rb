# frozen_string_literal: true

module Uuidable
  extend ActiveSupport::Concern

  included do
    include UUIDHelper
    before_save :set_uuid

    def set_uuid
      self.uuid ||= SecureRandom.uuid
    end
  end
end
