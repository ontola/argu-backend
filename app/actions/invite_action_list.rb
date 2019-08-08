# frozen_string_literal: true

class InviteActionList < ApplicationActionList
  has_action(
    :create,
    create_options.merge(
      collection: false,
      description: -> { I18n.t('tokens.discussion.description') },
      include_resource: true,
      label: -> { I18n.t('tokens.discussion.title') },
      policy: :create?,
      url: -> { iri_from_template(:tokens_iri) }
    )
  )

  private

  def association_class
    Invite
  end
end
