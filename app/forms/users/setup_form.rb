# frozen_string_literal: true

module Users
  class SetupForm < ApplicationForm
    class << self
      def intro_required
        @intro_required ||= [
          LinkedRails::SHACL::PropertyShape.new(
            path: [NS.ontola[:organization], NS.ontola[:requiresIntro]],
            has_value: true
          )
        ]
      end

      def terms_accepts
        @terms_accepts ||= [
          LinkedRails::SHACL::PropertyShape.new(
            path: [NS.argu[:acceptedTerms]],
            has_value: true
          )
        ]
      end
    end

    field :display_name, min_count: 1, if: intro_required
    field :display_name, unless: intro_required

    resource :confirmation_text,
             description: lambda {
               I18n.t('legal.continue_html',
                      policy: "[#{I18n.t('legal.documents.policy')}](#{ActsAsTenant.current_tenant.iri}/policy)",
                      privacy: "[#{I18n.t('legal.documents.privacy')}](#{ActsAsTenant.current_tenant.iri}/privacy)")
             },
             unless: terms_accepts
    hidden do
      field :accept_terms, default_value: true
      field :finished_intro, default_value: true
    end
  end
end
