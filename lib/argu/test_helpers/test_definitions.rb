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
            headers: @_argu_headers

        assert_response results[:response]
      end

      def general_create(results: {},
                         parent: nil,
                         attributes: {},
                         differences: [[model_class.to_s, 1],
                                       ['Activity.loggings', model_class.is_publishable? ? 2 : 1]],
                         **opts)
        parent = send(parent) if parent.is_a?(Symbol)
        attributes = default_create_attributes(parent: parent).merge(attributes)
        actor_iri = send(opts[:actor])&.context_id if opts[:actor].present?

        assert_differences(differences.map { |a, b| ["#{a}.count", results[:should] ? b : 0] }) do
          post create_path(parent),
               headers: @_argu_headers,
               params: {format: request_format, actor_iri: actor_iri, model_sym => attributes}

          reset_publication(Publication.last)
        end

        assert_response results[:response]
        analytics_collection_check(opts[:analytics], results[:analytics])
      end

      def general_show(results: {}, record: subject)
        record = send(record) if record.is_a?(Symbol)

        get record_path(record),
            params: {format: request_format},
            headers: @_argu_headers

        assert_response results[:response]
      end

      def general_edit(results: {}, record: subject)
        record = send(record) if record.is_a?(Symbol)

        get edit_path(record),
            params: {format: request_format},
            headers: @_argu_headers

        assert_response results[:response]
      end

      def general_update(results: {}, record: subject, attributes: {}, differences: [['Activity.loggings', 1]])
        record = record.is_a?(Symbol) ? send(record) : record.reload

        attributes = attributes_for(model_sym).merge(attributes)
        attributes[:edge_attributes][:id] = record.edge.id if attributes[:edge_attributes].present?
        ch_method = method(results[:should] ? :assert_not_equal : :assert_equal)

        assert_differences(differences.map { |a, b| ["#{a}.count", results[:should] ? b : 0] }) do
          patch update_path(record),
                headers: @_argu_headers,
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

      def general_trash(results: {}, analytics: nil, record: subject)
        record = send(record) if record.is_a?(Symbol)

        difference = results[:should] ? 1 : 0
        assert_differences([["#{model_class}.trashed.count", difference],
                            ['Activity.count', difference.abs]]) do
          delete trash_path(record),
                 params: {format: request_format},
                 headers: @_argu_headers
        end

        assert_response results[:response]
        analytics_collection_check(analytics, results[:analytics])
      end

      def general_destroy(results: {}, analytics: nil, record: subject,
                          differences: [[model_class.to_s, -1],
                                        ['Activity.loggings', 1]])
        record = send(record) if record.is_a?(Symbol)

        assert_differences(differences.map { |a, b| ["#{a}.count", results[:should] ? b : 0] }) do
          delete destroy_path(record),
                 params: {format: request_format},
                 headers: @_argu_headers
        end

        assert_response results[:response]
        analytics_collection_check(analytics, results[:analytics])
      end

      def general_shift(results: {}, record: subject)
        record = send(record) if record.is_a?(Symbol)

        get move_path(record),
            params: {format: request_format},
            headers: @_argu_headers

        assert_response results[:response]
      end

      def general_move(results: {}, record: subject, attributes: {})
        forum_to = send(attributes[:forum_id])
        assert_differences [["record.forum.reload.#{model_name.underscore}s.count",
                             results[:should] ? -1 : 0],
                            ["forum_to.reload.#{model_name.underscore}s.count",
                             results[:should] ? 1 : 0]] do
          put move_path(record),
              headers: @_argu_headers,
              params: {format: request_format, model_sym => attributes.merge(forum_id: forum_to.id)}
        end

        assert_response results[:response]
        return unless results[:should]
        assert_redirected_to record

        assert assigns(:resource)
        assert_equal forum_to, assigns(:resource).forum
        forum_id = forum_to.id
        case model_class
        when Motion
          assert assigns(:resource).arguments.count.positive?
          assigns(:resource).arguments.pluck(:forum_id).each do |id|
            assert_equal forum_id, id
          end
          assert assigns(:resource).question.blank?
        when Question
          assert record.forum != forum_to.id
          assigns(:resource).motions.pluck(:forum_id).each do |id|
            assert_equal record.forum.id, id
          end
          assert assigns(:resource).reload.motions.blank?
        end
        assert assigns(:resource).activities.count.positive?
        assigns(:resource).activities.pluck(:forum_id).each do |id|
          assert_equal forum_id, id
        end
        assigns(:resource).activities.pluck(:recipient_id).each do |id|
          assert_equal forum_id, id
        end
        assigns(:resource).activities.pluck(:recipient_type).each do |type|
          assert_equal 'Forum', type
        end
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
        url_for([:new, parent, model_sym])
      end

      def create_path(parent)
        url_for([parent, model_class])
      end

      def record_path(record)
        url_for([model_sym, id: record])
      end

      def edit_path(record)
        url_for([:edit, record])
      end

      def update_path(record)
        record_path(record)
      end

      def trash_path(record)
        record_path(record)
      end

      def destroy_path(record)
        url_for([record, destroy: true])
      end

      def move_path(record)
        url_for([record, :move])
      end

      def request_format
        :html
      end

      private

      def analytics_collection_check(analytics, results)
        if analytics.present? && results != false
          assert_analytics_collected(**analytics)
        else
          assert_analytics_not_collected
        end
      end
    end
  end
end
