module Publishable
  module Schemeable


    def schemeable_as(_schema_type, options = {})
      class_eval do
        include Publishable::Schema.const_get(_schema_type)
      end
    end

  end
end
