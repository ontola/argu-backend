# frozen_string_literal: true

module Uuidable
  extend ActiveSupport::Concern

  included do
    include UUIDHelper

    def initialize(opts = {})
      opts[:uuid] ||= SecureRandom.uuid
      self.class.reflect_on_all_associations.each { |a| association(a.name).loaded! } if new_record?
      super
    end
  end
end
