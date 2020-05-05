class CreateRIVMFooters < ActiveRecord::Migration[6.0]
  def up
    add_column :custom_menu_items, :parent_menu_id, :integer

    return unless Apartment::Tenant.current == 'rivm'

    Page.find_each do |page|
      ActsAsTenant.with_tenant(page) do
        service = CustomMenuItem.create!(menu_type: 'footer', resource: page, label: 'Service')
        CustomMenuItem.create!(parent_menu: service, menu_type: 'footer', resource: page, label: 'Contact', href: 'https://www.rivm.nl/contact')
        CustomMenuItem.create!(parent_menu: service, menu_type: 'footer', resource: page, label: 'Volg ons op Twitter', href: 'https://twitter.com/rivm', image: 'fa-twitter')
        CustomMenuItem.create!(parent_menu: service, menu_type: 'footer', resource: page, label: 'Volg ons op Facebook', href: 'http://www.facebook.com/RIVMnl', image: 'fa-facebook-square')
        CustomMenuItem.create!(parent_menu: service, menu_type: 'footer', resource: page, label: 'Volg ons op LinkedIn', href: 'https://nl.linkedin.com/company/rivm', image: 'fa-linkedin-square')
        CustomMenuItem.create!(parent_menu: service, menu_type: 'footer', resource: page, label: 'Volg ons op YouTube', href: 'https://www.youtube.com/user/RIVMnl', image: 'fa-youtube-play')
        CustomMenuItem.create!(parent_menu: service, menu_type: 'footer', resource: page, label: 'Volg ons op Instagram', href: 'https://www.instagram.com/rivmnl', image: 'fa-instagram')

        about = CustomMenuItem.create!(menu_type: 'footer', resource: page, label: 'Over deze site')
        CustomMenuItem.create!(parent_menu: about, menu_type: 'about', resource: page, label: 'Gebruikersvoorwaarden', href: "#{page.iri}/policy")
        CustomMenuItem.create!(parent_menu: about, menu_type: 'about', resource: page, label: 'Privacy', href: "#{page.iri}/privacy")

        page.set_template_option(
          'footerResources',
          [
            service.iri,
            about.iri,
            "#{page.iri}/u/language#EntryPoint",
          ].join(',')
        )
        page.save!
      end
    end
  end

  def down
    remove_column :custom_menu_items, :parent_menu_id, :integer

    CustomMenuItem.where(menu_type: 'footer').destroy_all
  end
end
