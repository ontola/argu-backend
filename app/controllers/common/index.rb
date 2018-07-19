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

      def collection_view_params
        params.permit(:before, :page, :page_size, :type)
      end

      def include_index
        collection_view_params.present? ? include_index_view : include_index_collection
      end

      def include_index_collection
        inc_nested_collection
      end

      def include_index_view
        {member_sequence: {members: include_show}}
      end

      def index_collection
        return if index_collection_association.blank?
        parent_resource!.send(
          index_collection_association,
          collection_options
        )
      end

      # @!visibility public
      def index_collection_association
        "#{model_name}_collection" if parent_resource!.respond_to?("#{model_name}_collection")
      end

      # @!visibility public
      def index_respond_blocks_success(_, format)
        format.html { index_respond_success_html }
        format.js { index_respond_success_js }
        format.json { index_respond_success_json }
        format.json_api { index_respond_success_serializer(:json_api) }
        RDF_CONTENT_TYPES.each do |type|
          format.send(type) { index_respond_success_serializer(type) }
        end
      end

      def index_response_association
        collection_view_params.present? ? index_collection&.view_with_opts(collection_view_params) : index_collection
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

      def index_respond_success_serializer(format)
        case format
        when :json_api
          render json: index_response_association, include: include_index
        else
          render format => index_response_association, meta: meta, include: include_index
        end
      end
    end
  end
end
