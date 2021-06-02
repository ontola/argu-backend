# frozen_string_literal: true

module Trashable
  module Action
    extend ActiveSupport::Concern

    included do
      include LinkedRails::Enhancements::Destroyable::Action

      has_action(
        :trash,
        type: [NS::ARGU[:TrashAction], NS::SCHEMA[:Action]],
        policy: :trash?,
        image: 'fa-trash',
        url: -> { resource.iri },
        http_method: :delete,
        form: Request::TrashRequestForm,
        root_relative_iri: lambda {
          expand_uri_template(:trash_iri, parent_iri: split_iri_segments(resource.root_relative_iri))
        }
      )

      has_action(
        :untrash,
        type: [NS::ARGU[:UntrashAction], NS::SCHEMA[:Action]],
        policy: :untrash?,
        image: 'fa-eye',
        url: -> { untrash_iri(resource) },
        http_method: :put,
        form: Request::UntrashRequestForm,
        root_relative_iri: lambda {
          expand_uri_template(:untrash_iri, parent_iri: split_iri_segments(resource.root_relative_iri))
        }
      )
    end
  end
end
