# frozen_string_literal: true

class TermActionList < ApplicationActionList
  has_action(
    :create,
    create_options.merge(
      collection: false,
      description: lambda do
        I18n.t('legal.continue_html',
               policy: "[#{I18n.t('legal.documents.policy')}](#{ActsAsTenant.current_tenant.iri}/policy)",
               privacy: "[#{I18n.t('legal.documents.privacy')}](#{ActsAsTenant.current_tenant.iri}/privacy)")
      end,
      label: -> { I18n.t('legal.documents.policy') },
      object: nil,
      policy: nil
    )
  )
end
