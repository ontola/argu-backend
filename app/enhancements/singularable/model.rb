# frozen_string_literal: true

module Singularable
  module Model
    extend ActiveSupport::Concern

    included do
      enhance LinkedRails::Enhancements::Singularable

      try(:before_redis_save, :mark_as_singular)
    end

    def cacheable?
      return false if singular_resource?

      super if defined?(super)
    end

    private

    def mark_as_singular
      self.singular_resource = true
    end
  end
end
