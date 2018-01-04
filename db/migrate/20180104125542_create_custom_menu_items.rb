class CreateCustomMenuItems < ActiveRecord::Migration[5.1]
  def change
    create_table :custom_menu_items do |t|
      t.string :menu_type, null: false
      t.string :resource_type, null: false
      t.integer :resource_id, null: false
      t.integer :order, null: false
      t.string :label
      t.boolean :label_translation, null: false, default: false
      t.string :image
      t.string :href, null: false
      t.string :policy
    end

    CustomMenuItem.create(
      menu_type: 'navigations',
      resource_type: 'Page',
      resource_id: 2,
      order: 0,
      label: 'about.about',
      label_translation: true,
      href: 'https://argu.localdev/i/about',
      image: 'fa-info'
    )
    CustomMenuItem.create(
      menu_type: 'navigations',
      resource_type: 'Page',
      resource_id: 2,
      order: 1,
      label: 'about.team',
      label_translation: true,
      href: 'https://argu.localdev/i/team',
      image: 'fa-info'
    )
    CustomMenuItem.create(
      menu_type: 'navigations',
      resource_type: 'Page',
      resource_id: 2,
      order: 2,
      label: 'about.contact',
      label_translation: true,
      href: 'https://argu.localdev/i/contact',
      image: 'fa-info'
    )
    CustomMenuItem.create(
      menu_type: 'navigations',
      resource_type: 'Page',
      resource_id: 2,
      order: 3,
      label: 'about.governments',
      label_translation: true,
      href: 'https://argu.localdev/i/governments',
      image: 'fa-info'
    )
  end
end
