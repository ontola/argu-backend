# frozen_string_literal: true

class PolicyAgreementActionList < ApplicationActionList
  has_collection_create_action(
    description: lambda do
      I18n.t('legal.continue_html',
             policy: "[#{I18n.t('legal.documents.policy')}](#{ActsAsTenant.current_tenant.iri}/policy)",
             privacy: "[#{I18n.t('legal.documents.privacy')}](#{ActsAsTenant.current_tenant.iri}/privacy)")
    end,
    label: -> { I18n.t('legal.documents.policy') },
    policy: nil
  )
end
