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
      url: -> { RDF::DynamicURI(expand_uri_template(:tokens_iri, with_hostname: true)) }
    )
  )

  private

  def association_class
    Invite
  end
end
