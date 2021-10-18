# frozen_string_literal: true

class PageForm < ApplicationForm
  field :display_name
  field :url
  field :primary_container_node_id,
        datatype: NS.xsd.string,
        max_count: 1,
        sh_in: -> { ContainerNode.collection_iri }
  field :locale

  group :theme,
        label: -> { I18n.t('forms.theme.label') },
        description: -> { I18n.t('forms.theme.description') } do
    has_one :default_profile_photo, min_count: 0
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
