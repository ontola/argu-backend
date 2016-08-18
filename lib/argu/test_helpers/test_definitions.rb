# frozen_string_literal: true

module Argu
  module TestHelpers
    module TestDefinitions
      def default_create_attributes(opts= {})
        attributes_for(model_sym)
      end

      # General methods
      def general_new(results: {}, parent: nil)
        get new_path(send(parent))

        assert_response results[:response]
      end

      def general_create(results: {},
                         parent: nil,
                         attributes: {},
                         differences: [[model_class.to_s, 1], ['Activity.loggings', 1]],
                         **opts)
        parent = send(parent) if parent.is_a?(Symbol)
        attributes = default_create_attributes(parent: parent).merge(attributes)
        change_actor send(opts[:actor]) if opts[:actor].present?

        assert_differences(differences.map { |a, b| ["#{a}.count", results[:should] ? b : 0] }) do
          post create_path(parent),
               params: {model_sym => attributes}

          if Publication.any?
            Sidekiq::Testing.inline! do
              Publication.last.send(:reset)
            end
          end
        end

        assert_response results[:response]
        analytics_collection_check(opts[:analytics], results[:analytics])
      end

      def general_show(results: {}, record: subject)
        record = send(record) if record.is_a?(Symbol)

        get record_path(record)

        assert_response results[:response]
      end

      def general_edit(results: {}, record: subject)
        record = send(record) if record.is_a?(Symbol)

        get edit_path(record)

        assert_response results[:response]
      end

      def general_update(results: {}, record: subject, attributes: {})
        record = record.is_a?(Symbol) ? send(record) : record.reload

        attributes = attributes_for(model_sym).merge(attributes)
        ch_method = method(results[:should] ? :assert_not_equal : :assert_equal)

        assert_difference('Activity.loggings.count', results[:should] ? 1 : 0) do
          patch update_path(record),
                params: {model_sym => attributes}
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
        assert_differences([["#{model_class}.trashed_only.count", difference],
                            ['Activity.count', difference.abs]]) do
          delete update_path(record)
        end

        assert_response results[:response]
        analytics_collection_check(analytics, results[:analytics])
      end

      def general_destroy(results: {}, analytics: nil, record: subject,
                          differences: [[model_class.to_s, -1],
                                        ['Activity.loggings', 1]])
        record = send(record) if record.is_a?(Symbol)

        assert_differences(differences.map { |a, b| ["#{a}.count", results[:should] ? b : 0] }) do
          delete destroy_path(record)
        end

        assert_response results[:response]
        analytics_collection_check(analytics, results[:analytics])
      end

      def general_move(results: {}, record: subject)
        record = send(record) if record.is_a?(Symbol)

        get move_path(record)

        assert_response results[:response]
      end

      def general_move!(results: {}, record: subject, attributes: {})
        forum_to = send(attributes[:forum_id])
        assert_differences [["record.forum.reload.#{model_name.underscore}s.count",
                             results[:should] ? -1 : 0],
                            ["forum_to.reload.#{model_name.underscore}s.count",
                             results[:should] ? 1 : 0]] do
          put move_path(record),
              params: {model_sym => attributes.merge(forum_id: forum_to.id)}
        end

        assert_response results[:response]
        if results[:should]
          assert_redirected_to record

          assert assigns(model_sym)
          assert_equal forum_to, assigns(model_sym).forum
          forum_id = forum_to.id
          case model_class
          when Motion
            assert assigns(:motion).arguments.count > 0
            assigns(:motion).arguments.pluck(:forum_id).each do |id|
              assert_equal forum_id, id
            end
            assert assigns(:motion).question.blank?
          when Question
            assert record.forum != forum_to.id
            assigns(:question).motions.pluck(:forum_id).each do |id|
              assert_equal record.forum.id, id
            end
            assert assigns(:question).reload.motions.blank?
          end
          assert assigns(model_sym).activities.count > 0
          assigns(model_sym).activities.pluck(:forum_id).each do |id|
            assert_equal forum_id, id
          end
          assigns(model_sym).taggings.pluck(:forum_id).each do |id|
            assert_equal forum_id, id
          end
        else
          assert_redirected_to record.forum
        end
      end

      # Model names
      def model_class
        model_name.constantize
      end

      def model_name
        self.class.name.split('ControllerTest').first.singularize
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

      def destroy_path(record)
        url_for([record, destroy: true])
      end

      def move_path(record)
        url_for([record, :move])
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
