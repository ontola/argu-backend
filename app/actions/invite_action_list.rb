# frozen_string_literal: true

class InviteActionList < ApplicationActionList
  has_collection_create_action(
    description: -> { I18n.t('tokens.discussion.description') },
    label: -> { I18n.t('tokens.discussion.title') },
    url: -> { LinkedRails.iri(path: 'tokens/email') }
  )
end
