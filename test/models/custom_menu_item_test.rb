# frozen_string_literal: true

require 'test_helper'

class CustomMenuItemTest < ActiveSupport::TestCase
  define_freetown
  let(:custom_menu_item) do
    CustomMenuItem.create(
      menu_type: 'navigations',
      resource_type: 'Page',
      resource_id: freetown.page_id,
      order: 0,
      label: 'Custom label',
      label_translation: false,
      href: 'https://argu.localdev/i/about',
      image: 'fa-info'
    )
  end
  let(:team_menu_item) do
    CustomMenuItem.create(
      menu_type: 'navigations',
      resource_type: 'Page',
      resource_id: freetown.page_id,
      order: 0,
      label: 'about.team',
      label_translation: true,
      href: 'https://argu.localdev/i/about',
      image: 'fa-info'
    )
  end

  test 'team menu item translation' do
    assert_equal team_menu_item.label, 'Our team'
  end

  test 'custom menu item translation' do
    assert_equal custom_menu_item.label, 'Custom label'
  end
end
