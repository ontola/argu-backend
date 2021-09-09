# frozen_string_literal: true

class PolicyAgreementsController < ApplicationController
  has_collection_create_action(
    description: lambda do
      I18n.t('legal.continue_html',
             policy: "[#{I18n.t('legal.documents.policy')}](#{ActsAsTenant.current_tenant.iri}/policy)",
             privacy: "[#{I18n.t('legal.documents.privacy')}](#{ActsAsTenant.current_tenant.iri}/privacy)")
    end,
    label: -> { I18n.t('legal.documents.policy') },
    policy: nil
  )

  private

  def create_execute
    current_user.update(accept_terms: true)
    current_user.send_reset_password_token_email if current_user.encrypted_password.blank?
    true
  end

  def create_success
    head 200
  end
end
