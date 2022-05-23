# frozen_string_literal: true

class MediaObjectsController < ParentableController
  extend URITemplateHelper

  has_collection_create_action(
    image: font_awesome_iri('paperclip')
  )
end
