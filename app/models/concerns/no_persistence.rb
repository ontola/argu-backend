# frozen_string_literal: true

require 'argu/errors/no_persistence'
module NoPersistence
  extend ActiveSupport::Concern
  included do
    def raise_on_persisting(_opts = {})
      raise Argu::Errors::NoPersistence.new("#{self.class.name} should not be persisted")
    end
    ActiveRecord::Persistence.instance_methods.each do |method|
      alias_method method, :raise_on_persisting unless method.to_s.include?('?')
    end
  end
end
