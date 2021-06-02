# frozen_string_literal: true

module DefaultActions
  module Trash
    def has_resource_trash_action(overwrite = {})
      has_resource_action(:trash, trash_resource_options(overwrite))
    end

    def has_singular_trash_action(overwrite = {})
      has_singular_action(:trash, trash_singular_options(overwrite))
    end

    def has_resource_untrash_action(overwrite = {})
      has_resource_action(:untrash, untrash_resource_options(overwrite))
    end

    def has_singular_untrash_action(overwrite = {})
      has_singular_action(:untrash, untrash_singular_options(overwrite))
    end

    private

    def default_trash_options(overwrite = {}) # rubocop:disable Metrics/MethodLength
      {
        form: Request::TrashRequestForm,
        http_method: :delete,
        image: 'fa-trash',
        policy: :trash?,
        root_relative_iri: lambda {
          expand_uri_template(:trash_iri, parent_iri: split_iri_segments(resource.root_relative_iri))
        },
        type: [NS::ARGU[:TrashAction], NS::SCHEMA[:Action]],
        url: -> { resource.iri }
      }.merge(overwrite)
    end

    def default_untrash_options(overwrite = {}) # rubocop:disable Metrics/MethodLength
      {
        form: Request::UntrashRequestForm,
        http_method: :put,
        image: 'fa-eye',
        policy: :untrash?,
        root_relative_iri: lambda {
          expand_uri_template(:untrash_iri, parent_iri: split_iri_segments(resource.root_relative_iri))
        },
        type: [NS::ARGU[:UntrashAction], NS::SCHEMA[:Action]],
        url: -> { untrash_iri(resource) }
      }.merge(overwrite)
    end

    def trash_resource_options(overwrite)
      default_trash_options.merge(overwrite)
    end

    def trash_singular_options(overwrite)
      default_trash_options(
        url: -> { resource.singular_iri }
      ).merge(overwrite)
    end

    def untrash_resource_options(overwrite)
      default_untrash_options.merge(overwrite)
    end

    def untrash_singular_options(overwrite)
      default_untrash_options(
        url: -> { untrash_iri(resource.root_relative_singular_iri) }
      ).merge(overwrite)
    end
  end
end
