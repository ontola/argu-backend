# frozen_string_literal: true

class CustomMenuItemActionList < ApplicationActionList
  has_action(
    :update,
    update_options.merge(
      root_relative_iri: lambda {
        uri = resource.root_relative_canonical_iri.dup
        uri.path ||= ''
        uri.path += '/edit'
        uri.to_s
      },
      url: -> { resource.canonical_iri }
    )
  )
  has_action(
    :destroy,
    destroy_options.merge(
      root_relative_iri: lambda {
        uri = resource.root_relative_canonical_iri.dup
        uri.path ||= ''
        uri.path += '/delete'
        uri.to_s
      },
      url: -> { resource.canonical_iri }
    )
  )
end
