# frozen_string_literal: true

module Request
  class Base
    include ActiveModel::Model
    include ActiveModel::AttributeMethods
    include ActiveRecord::Core
    include ActiveRecord::DefineCallbacks
    include ActiveRecord::Associations
    include ActiveRecord::AttributeDecorators
    include ActiveRecord::AttributeMethods
    include ActiveRecord::AutosaveAssociation
    include ActiveRecord::Reflection
    include ActiveRecord::NestedAttributes
    include Enhanceable

    class << self
      def pluralize_table_names
        true
      end

      private

      def reload_schema_from_cache; end

      def scope(*_opts); end
    end
  end
end
