# frozen_string_literal: true

class InvitesController < ParentableController
  has_collection_create_action(
    target_url: -> { LinkedRails.iri(path: 'tokens') }
  )
end
