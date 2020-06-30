# frozen_string_literal: true

class PageForm < ApplicationForm
  field :display_name
  field :url
  field :primary_container_node_id,
        datatype: NS::XSD[:string],
        max_count: 1,
        sh_in: -> { collection_iri(nil, :container_nodes) }
  field :accepted_terms
  resource :delete_button, url: -> { delete_iri(ActsAsTenant.current_tenant) }

  group :theme,
        label: -> { I18n.t('forms.theme.label') },
        description: -> { I18n.t('forms.theme.description') } do
    has_one :default_profile_photo, min_count: 0
    field :navbar_color
    field :navbar_background
    field :accent_color
    field :accent_background_color
    field :styled_headers
  end
end
