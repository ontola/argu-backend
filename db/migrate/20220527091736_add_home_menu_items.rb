class AddHomeMenuItems < ActiveRecord::Migration[7.0]
  def change
    Page.find_each do |page|
      item = page.navigations_menu_items.new(edge: page)
      if page.default_profile_photo.present? && !page.default_profile_photo.gravatar_url?
        item.custom_image.attach(io: URI.open(page.default_profile_photo.content.url), filename: page.default_profile_photo.filename)

        Apartment::Tenant.switch!(Apartment::Tenant.current)
      end
      item.insert_at!
    end
  end
end
