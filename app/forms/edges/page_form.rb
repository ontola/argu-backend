# frozen_string_literal: true

class PageForm < ApplicationForm
  field :display_name,
        min_count: 1,
        placeholder: ''
  field :url,
        start_adornment: "#{Rails.application.config.origin}/"
  field :tier
  field :primary_container_node_id,
        datatype: NS.xsd.string,
        max_count: 1,
        sh_in: -> { ContainerNode.collection_iri }
  field :language,
        min_count: 1
  field :requires_intro
  has_one :default_profile_photo, min_count: 0
  resource :delete,
           label: -> { I18n.t('delete') },
           url: -> { delete_iri(ActsAsTenant.current_tenant) }

  group :analytics,
        label: -> { I18n.t('forms.analytics') } do
    field :matomo_site_id
    field :matomo_host
    field :matomo_cdn
    field :piwik_pro_site_id
    field :piwik_pro_host
    field :google_tag_manager
    field :google_uac
  end

  resource :confirmation_text,
           description: lambda {
             I18n.t('legal.continue_html',
                    policy: "[#{I18n.t('legal.documents.policy')}](#{ActsAsTenant.current_tenant.iri}/policy)",
                    privacy: "[#{I18n.t('legal.documents.privacy')}](#{ActsAsTenant.current_tenant.iri}/privacy)")
           }
end
