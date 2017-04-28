# frozen_string_literal: true
module Service
  module Index
    extend ActiveSupport::Concern

    included do
      define_handlers(:index)

      def index
        skip_verify_policy_scoped(true)
        index_handler_success(nil)
      end

      private

      # @!visibility public
      def index_collection_association
        "#{model_name}_collection"
      end

      def include_index
        ::INC_NESTED_COLLECTION
      end

      # @!visibility public
      def index_respond_blocks_success(_, format)
        format.json_api do
          render json: get_parent_resource.send(index_collection_association, collection_options),
                 include: include_index
        end
      end
    end
  end
end
