# frozen_string_literal: true

module Argu
  module TestHelpers
    module TestDefinitions
      def default_create_attributes(_opts = {})
        attributes_for(model_sym)
      end

      # General methods
      def general_new(results: {}, parent: nil)
        get new_path(send(parent)),
            params: {format: request_format},
            headers: argu_headers

        assert_response results[:response]
      end

      def general_create(results: {}, # rubocop:disable Metrics/AbcSize
                         parent: nil,
                         attributes: {},
                         differences: [[model_class.to_s, 1],
                                       ['Activity', model_class.is_publishable? ? 2 : 1]],
                         **opts)
        parent = send(parent) if parent.is_a?(Symbol)
        attributes = default_create_attributes(parent: parent).merge(attributes)
        actor_iri = send(opts[:actor])&.iri if opts[:actor].present?

        assert_difference(Hash[differences.map { |a, b| ["#{a}.count", results[:should] ? b : 0] }]) do
          post create_path(parent),
               headers: argu_headers,
               params: {format: request_format, actor_iri: actor_iri, model_sym => attributes}

          ActsAsTenant.with_tenant(Publication.last.publishable.root) { reset_publication(Publication.last) }
        end

        assert_response results[:response]
      end

      def general_show(results: {}, record: subject)
        record = send(record) if record.is_a?(Symbol)

        get record_path(record),
            params: {format: request_format},
            headers: argu_headers

        assert_response results[:response]
      end

      def general_edit(results: {}, record: subject)
        record = send(record) if record.is_a?(Symbol)

        get edit_path(record),
            params: {format: request_format},
            headers: argu_headers

        assert_response results[:response]
      end

      # rubocop:disable Metrics/AbcSize
      def general_update(results: {}, record: subject, attributes: {}, differences: [['Activity', 1]])
        record = record.is_a?(Symbol) ? send(record) : record.reload

        attributes = attributes_for(model_sym).merge(attributes)
        ch_method = method(results[:should] ? :assert_not_equal : :assert_equal)

        assert_difference(Hash[differences.map { |a, b| ["#{a}.count", results[:should] ? b : 0] }]) do
          patch update_path(record),
                headers: argu_headers,
                params: {format: request_format, model_sym => attributes}
        end

        assert_response results[:response]
        if assigns(:update_service).try(:resource).present?
          ch_method.call record
                           .updated_at
                           .iso8601(6),
                         assigns(:update_service)
                           .try(:resource)
                           .try(:updated_at)
                           .try(:iso8601, 6)
        elsif results[:should]
          assert false, "can't be changed"
        end
      end
      # rubocop:enable Metrics/AbcSize

      def general_trash(results: {}, record: subject)
        record = send(record) if record.is_a?(Symbol)

        difference = results[:should] ? 1 : 0
        assert_difference("#{model_class}.trashed.count" => difference,
                          'Activity.count' => difference.abs) do
          delete trash_path(record),
                 params: {format: request_format},
                 headers: argu_headers
        end

        assert_response results[:response]
      end

      def general_destroy(results: {}, record: subject,
                          differences: [[model_class.to_s, -1],
                                        ['Activity', 1]])
        record = send(record) if record.is_a?(Symbol)

        assert_difference(Hash[differences.map { |a, b| ["#{a}.count", results[:should] ? b : 0] }]) do
          delete destroy_path(record),
                 params: {format: request_format},
                 headers: argu_headers
        end

        assert_response results[:response]
      end

      # Model names
      def model_class
        model_name.constantize
      end

      def model_name
        self.class.name.split('Test').first.singularize
      end

      def model_sym
        model_name.underscore.to_sym
      end

      # Paths
      def new_path(parent)
        new_iri(parent, model_name.tableize).path
      end

      def create_path(parent)
        collection_iri(parent, model_name.tableize).path
      end

      def record_path(record)
        resource_iri(record).path
      end

      def edit_path(record)
        edit_iri(record).path
      end

      def update_path(record)
        record_path(record)
      end

      def trash_path(record)
        record_path(record)
      end

      def destroy_path(record)
        record.iri(destroy: true).to_s
      end

      def move_path(record)
        move_iri(record).path
      end

      def request_format
        :html
      end
    end
  end
end
