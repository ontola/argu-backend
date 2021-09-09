# frozen_string_literal: true

module Trashable
  module Controller
    extend ActiveSupport::Concern

    included do
      extend Trashable::DefaultActions
      include LinkedRails::Enhancements::Destroyable::Controller

      has_resource_trash_action
      has_resource_untrash_action
    end

    private

    def action_service
      return trash_service if trash_request?
      return untrash_service if untrash_request?

      super
    end

    def activity_attributes_key
      return super unless trash_request?

      :trash_activity_attributes
    end

    def authorize_action
      return super unless trash_request?

      authorize(current_resource!, :trash?)
    end

    def destroy_success
      return super unless trash_request?

      respond_with_updated_resource(trash_success_options)
    end

    def destroy_success_message
      return I18n.t('type_destroy_success', type: current_resource.class.label.capitalize) unless trash_request?

      I18n.t('type_trash_success', type: current_resource.class.label.capitalize)
    end

    def signals_failure
      return super unless trash_request?

      [:"trash_#{model_name}_failed"]
    end

    def signals_success
      return super unless trash_request?

      [:"trash_#{model_name}_successful"]
    end

    # Prepares a memoized {TrashService} for the relevant model for use in controller#trash
    # @return [TrashService] The service, generally initialized with {resource_id}
    # @example
    #   trash_service # => TrashComment<commentable_id: 6, parent_id: 5>
    #   trash_service.commit # => true (Comment trashed)
    def trash_service
      @trash_service ||= service_klass('trash').new(
        requested_resource!,
        options: service_options
      )
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

    def trash_request?
      action_name == 'destroy' && params[:destroy].to_s != 'true'
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

    def untrash_request?
      action_name == 'untrash'
    end

    # Prepares a memoized {UntrashService} for the relevant model for use in controller#untrash
    # @return [UntrashService] The service, generally initialized with {resource_id}
    # @example
    #   untrash_service # => UntrashComment<commentable_id: 6, parent_id: 5>
    #   untrash_service.commit # => true (Comment untrashed)
    def untrash_service
      @untrash_service ||= service_klass.new(
        requested_resource!,
        options: service_options
      )
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
