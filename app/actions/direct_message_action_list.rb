# frozen_string_literal: true

class DirectMessageActionList < ApplicationActionList
  has_collection_create_action(
    description: lambda {
      I18n.t('actions.direct_messages.create.description', creator: resource.parent.publisher.display_name)
    },
    label: -> { I18n.t('actions.direct_messages.create.label') }
  )
end
