# frozen_string_literal: true

module Trashable
  module Controller
    extend ActiveSupport::Concern

    included do
      include LinkedRails::Enhancements::Destroyable::Controller

      active_response :trash, :untrash
    end

    private

    def trash_failure
      respond_with_invalid_resource(trash_failure_options)
    end

    def trash_failure_options
      update_failure_options
    end

    def trash_meta # rubocop:disable Metrics/AbcSize
      trash_activity = current_resource.dup.trash_activity
      menu = current_resource.menu(:actions)
      resource_removed_delta(current_resource) + [
        [current_resource.iri, NS.argu[:trashActivity], trash_activity.iri, delta_iri(:replace)],
        [current_resource.iri, NS.argu[:trashedAt], current_resource.trashed_at, delta_iri(:replace)],
        [menu.menu_sequence_iri, NS.sp.Variable, NS.sp.Variable, delta_iri(:invalidate)]
      ]
    end

    def trash_success
      respond_with_updated_resource(trash_success_options)
    end

    def trash_success_options
      opts = update_success_options
      opts[:meta] = trash_meta
      opts
    end

    def untrash_failure
      respond_with_invalid_resource(untrash_failure_options)
    end

    def untrash_failure_options
      update_failure_options
    end

    def untrash_meta # rubocop:disable Metrics/AbcSize
      menu = current_resource.menu(:actions)
      resource_added_delta(current_resource) + [
        [current_resource.iri, NS.argu[:trashActivity], NS.sp.Variable, delta_iri(:remove)],
        [current_resource.iri, NS.argu[:trashedAt], NS.sp.Variable, delta_iri(:remove)],
        [menu.menu_sequence_iri, NS.sp.Variable, NS.sp.Variable, delta_iri(:invalidate)]
      ]
    end

    def untrash_success
      respond_with_updated_resource(untrash_success_options)
    end

    def untrash_success_options
      opts = update_success_options
      opts[:meta] = untrash_meta
      opts
    end
  end
end
