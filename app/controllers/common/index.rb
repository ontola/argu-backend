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
        format.html { index_respond_success_html }
        format.js { index_respond_success_js }
        format.json { index_respond_success_json }
        format.json_api { index_respond_success_json_api }
        format.n3 { index_respond_success_n3 }
        format.nt { index_respond_success_nt }
      end

      def index_response_association
        parent_resource!.send(
          index_collection_association,
          collection_options
        )
      end

      def index_respond_success_html
        raise NotImplementedError
      end

      def index_respond_success_js
        raise NotImplementedError
      end

      def index_respond_success_json
        raise NotImplementedError
      end

      def index_respond_success_json_api
        render json: index_response_association,
               include: include_index
      end

      def index_respond_success_nt
        render nt: index_response_association,
               include: include_index
      end
    end
  end
end
