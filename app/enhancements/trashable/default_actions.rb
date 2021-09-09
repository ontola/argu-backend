# frozen_string_literal: true

module Trashable
  module DefaultActions
    def has_resource_trash_action(overwrite = {})
      has_resource_action(:trash, **trash_resource_options(overwrite))
    end

    def has_singular_trash_action(overwrite = {})
      has_singular_action(:trash, **trash_singular_options(overwrite))
    end

    def has_resource_untrash_action(overwrite = {})
      has_resource_action(:untrash, **untrash_resource_options(overwrite))
    end

    def has_singular_untrash_action(overwrite = {})
      has_singular_action(:untrash, **untrash_singular_options(overwrite))
    end

    private

    def default_trash_options(overwrite = {})
      {
        form: TrashForm,
        http_method: :delete,
        image: 'fa-trash',
        policy: :trash?,
        target_url: -> { resource.iri },
        type: [NS.argu[:TrashAction], NS.schema.Action]
      }.merge(overwrite)
    end

    def default_untrash_options(overwrite = {})
      {
        form: UntrashForm,
        http_method: :put,
        image: 'fa-eye',
        policy: :untrash?,
        target_path: :untrash,
        type: [NS.argu[:UntrashAction], NS.schema.Action]
      }.merge(overwrite)
    end

    def trash_resource_options(overwrite)
      default_trash_options.merge(overwrite)
    end

    def trash_singular_options(overwrite)
      default_trash_options(
        target_url: -> { resource.singular_iri }
      ).merge(overwrite)
    end

    def untrash_resource_options(overwrite)
      default_untrash_options.merge(overwrite)
    end

    def untrash_singular_options(overwrite)
      default_untrash_options(
        target_url: -> { untrash_iri(resource.root_relative_singular_iri) }
      ).merge(overwrite)
    end
  end
end
