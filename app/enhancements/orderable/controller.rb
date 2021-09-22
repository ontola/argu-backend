# frozen_string_literal: true

module Orderable
  module Controller
    extend ActiveSupport::Concern

    included do
      has_resource_action(
        :move_up,
        http_method: :put,
        image: 'fa-chevron-up',
        one_click: true,
        policy: :move_up?
      )
      has_resource_action(
        :move_down,
        http_method: :put,
        image: 'fa-chevron-down',
        one_click: true,
        policy: :move_down?
      )
    end

    def move_meta # rubocop:disable Metrics/AbcSize
      delta = update_meta + invalidate_parent_collections_delta(current_resource)
      delta << invalidate_resource_delta(current_resource.lower_item) if current_resource.lower_item
      delta << invalidate_resource_delta(current_resource.higher_item) if current_resource.higher_item
      delta
    end

    def move_up_execute
      current_resource.move_higher || true
    end

    def move_up_success
      respond_with_updated_resource(move_up_success_options)
    end

    def move_up_success_message; end

    def move_up_success_options
      update_success_options.merge(meta: move_meta)
    end

    def move_down_execute
      current_resource.move_lower || true
    end

    def move_down_success
      respond_with_updated_resource(move_down_success_options)
    end

    def move_down_success_message; end

    def move_down_success_options
      update_success_options.merge(meta: move_meta)
    end
  end
end
