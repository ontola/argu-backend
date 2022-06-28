# frozen_string_literal: true

class PageForm < ApplicationForm
  field :display_name,
        min_count: 1,
        placeholder: ''
  field :url,
        start_adornment: "#{Rails.application.config.origin}/"
  field :primary_container_node_id,
        datatype: NS.xsd.string,
        max_count: 1,
        sh_in: -> { ContainerNode.collection_iri }
  field :locale,
        min_count: 1
  has_one :default_profile_photo, min_count: 0
  resource :delete,
           label: -> { I18n.t('delete') },
           description: -> { I18n.t('pages.settings.advanced.delete.only_without_components') },
           url: -> { delete_iri(ActsAsTenant.current_tenant) }

  group :theme,
        label: -> { I18n.t('forms.theme.label') },
        description: -> { I18n.t('forms.theme.description') } do
    field :primary_color,
          input_field: LinkedRails::Form::Field::ColorInput
    field :secondary_color,
          input_field: LinkedRails::Form::Field::ColorInput
    field :header_background
    field :header_text
    field :styled_headers
  end
  group :staff,
        label: -> { I18n.t('forms.staff_only') } do
    field :requires_intro
    field :matomo_site_id
    field :matomo_host
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
