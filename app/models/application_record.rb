# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  MAXIMUM_DESCRIPTION_LENGTH = 20_000

  include LinkedRails::Model
  include ApplicationModel
  include VirtualAttributes

  self.abstract_class = true

  def build_child(klass, opts = {})
    ChildHelper.child_instance(self, klass, opts)
  end

  class << self
    def collection_include_map
      JSONAPI::IncludeDirective::Parser.parse_include_args([:root] + [show_includes])
    end
  end
end
