# frozen_string_literal: true

Tenant.setup_schema('rivm', "#{Rails.application.config.host_name}/omgevingsveiligheid", 'omgevingsveiligheid')

Apartment::Tenant.switch('rivm') do
  @actions = HashWithIndifferentAccess.new

  ActsAsTenant.with_tenant(Page.first) do
    Page.first.update!(primary_color: '#007BC7')

    CustomMenuItem.create!(
      menu_type: :navigations,
      resource: Page.first,
      position: 0,
      label: InterventionType.plural_label,
      href: InterventionType.root_collection.iri
    )
  end
end
