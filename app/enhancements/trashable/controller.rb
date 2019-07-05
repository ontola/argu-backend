# frozen_string_literal: true

module Trashable
  module Controller
    extend ActiveSupport::Concern

    included do
      include LinkedRails::Enhancements::Destroyable::Controller

      active_response :bin, :trash, :unbin, :untrash
    end

    private

    def bin_success
      respond_with_form(bin_success_options)
    end

    def bin_success_options
      default_form_options(:bin)
    end

    def unbin_success
      respond_with_form(unbin_success_options)
    end

    def unbin_success_options
      default_form_options(:unbin)
    end

    def trash_failure
      redirect_with_invalid_resource(trash_failure_options)
    end

    def trash_failure_options
      update_failure_options
    end

    def trash_meta
      remove_resource_delta(current_resource)
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
      redirect_with_invalid_resource(untrash_failure_options)
    end

    def untrash_failure_options
      opts = update_success_options
      opts[:meta] = untrash_meta
      opts
    end

    def untrash_meta
      add_resource_delta(current_resource)
    end

    def untrash_success
      respond_with_updated_resource(untrash_success_options)
    end

    def untrash_success_options
      update_success_options
    end
  end
end
