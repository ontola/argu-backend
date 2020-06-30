# frozen_string_literal: true

class DirectMessageActionList < ApplicationActionList
  has_action(
    :create,
    create_options.merge(
      collection: false,
      description: lambda {
        I18n.t('actions.direct_messages.create.description', creator: resource.resource.publisher.display_name)
      },
      object: nil,
      include_object: true,
      label: -> { I18n.t('actions.direct_messages.create.label') },
      policy: :create?
    )
  )
end
