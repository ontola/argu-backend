# frozen_string_literal: true

require 'test_helper'

class CustomMenuItemTest < ActiveSupport::TestCase
  define_freetown
  let(:custom_menu_item) do
    CustomMenuItem.create(
      menu_type: 'navigations',
      resource_type: 'Edge',
      resource_id: argu.uuid,
      label: 'Custom label',
      href: 'https://argu.localdev/i/about',
      icon: 'fa-info'
    )
  end
  let(:team_menu_item) do
    CustomMenuItem.create(
      menu_type: 'navigations',
      resource_type: 'Edge',
      resource_id: argu.uuid,
      label: 'set_language',
      href: 'https://argu.localdev/i/about',
      icon: 'fa-info'
    )
  end

  test 'team menu item translation' do
    match = team_menu_item.label.detect { |label| label.to_s == 'Set language' }
    assert match
  end

  test 'custom menu item translation' do
    assert_equal custom_menu_item.label, 'Custom label'
  end
end
