# frozen_string_literal: true

module Common
  module Index
    extend ActiveSupport::Concern

    included do
      define_handlers(:index)

      def index
        skip_verify_policy_scoped(true)
        index_handler_success(nil)
      end

      private

      def include_index
        inc_nested_collection
      end

      # @!visibility public
      def index_collection_association
        "#{model_name}_collection"
      end

      # @!visibility public
      def index_respond_blocks_success(_, format)
        format.json_api do
          render json: index_response_association,
                 include: include_index
        end
        format.n3 do
          render n3: index_response_association,
                 include: include_index
        end
      end

      def index_response_association
        parent_resource!.send(
          index_collection_association,
          collection_options
        )
      end
    end
  end
end
