# frozen_string_literal: true
module ActiveModelSerializers
  module Adapter
    class JsonApi
      class ResourceIdentifier
        def type_for(serializer)
          return serializer._type.call(serializer.object) if serializer._type.respond_to?(:call)
          return serializer._type.to_s if serializer._type
          if ActiveModelSerializers.config.jsonapi_resource_type == :singular
            serializer.object.class.model_name.singular
          else
            serializer.object.class.model_name.plural
          end
        end
      end
    end
  end
end
