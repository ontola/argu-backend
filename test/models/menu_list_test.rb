# frozen_string_literal: true

require 'test_helper'

class MenuListTest < ActiveSupport::TestCase
  define_freetown
  define_freetown('second', attributes: {public_grant: 'none'})
  let(:other_page) { create(:page) }

  let(:user) { create(:user) }
  let(:user_context) do
    UserContext.new(
      doorkeeper_scopes: {},
      profile: user.profile,
      tree_root: argu.root,
      user: user
    )
  end
  let(:other_page_context) do
    UserContext.new(
      doorkeeper_scopes: {},
      profile: user.profile,
      tree_root: other_page.root,
      user: user
    )
  end

  let(:administrator) { create_administrator(argu) }
  let(:administrator_context) do
    UserContext.new(
      doorkeeper_scopes: {},
      profile: administrator.profile,
      tree_root: argu.root,
      user: administrator
    )
  end

  let!(:custom_menu_item) do
    CustomMenuItem.create(
      menu_type: 'navigations',
      resource_type: 'Edge',
      resource_id: argu.uuid,
      order: 0,
      label: 'Custom label',
      label_translation: false,
      href: 'https://argu.localdev/i/about',
      image: 'fa-info'
    )
  end

  test 'Menu for administrator should include update' do
    assert freetown.menu(administrator_context, :actions).menus.call.compact.map(&:tag).include?(:edit)
  end

  test 'Menu for user should not include update' do
    assert_equal freetown.menu(user_context, :actions).menus.call.compact.map(&:tag), %i[activity]
  end

  test 'Page menu for administrator should include hidden forum' do
    assert argu.menu(administrator_context, :navigations).menus.call.compact.map(&:tag).include?(:second)
  end

  test 'Page menu for user should not include hidden forum' do
    assert_not argu.menu(user_context, :navigations).menus.call.compact.map(&:tag).include?(:second)
  end

  test 'Include custom menu items' do
    assert_equal(
      'Custom label',
      freetown
        .root
        .menu(user_context, :navigations)
        .menus
        .call
        .compact
        .find { |f| f.tag == "custom_#{custom_menu_item.id}" }
        .label
    )
  end

  test 'Do not include custom menu items if other page' do
    assert_nil(
      other_page
        .menu(other_page_context, :navigations)
        .menus
        .call
        .compact
        .find { |f| f.tag == "custom_#{custom_menu_item.id}" }
    )
  end
end
