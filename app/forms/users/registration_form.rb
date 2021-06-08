# frozen_string_literal: true

module Users
  class RegistrationForm < ApplicationForm
    field :email, input_field: LinkedRails::Form::Field::EmailInput, min_count: 1
    resource :confirmation_text,
             description: lambda {
               I18n.t('legal.continue_html',
                      policy: "[#{I18n.t('legal.documents.policy')}](#{ActsAsTenant.current_tenant.iri}/policy)",
                      privacy: "[#{I18n.t('legal.documents.privacy')}](#{ActsAsTenant.current_tenant.iri}/privacy)")
             }
    hidden do
      field :redirect_url
      field :accept_terms, default_value: true
    end
  end
end
