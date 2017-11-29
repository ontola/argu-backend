# frozen_string_literal: true

require 'test_helper'

class MenuListTest < ActiveSupport::TestCase
  define_freetown
  define_freetown('second', attributes: {public_grant: 'none'})

  let(:user) { create(:user) }
  let(:user_context) { UserContext.new(user, user.profile, {}, GrantTree::ANY_ROOT) }

  let(:administrator) { create_administrator(freetown.page) }
  let(:administrator_context) { UserContext.new(administrator, administrator.profile, {}, GrantTree::ANY_ROOT) }

  let!(:custom_menu_item) do
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

  test 'Menu for administrator should include update' do
    assert freetown.menu(administrator_context, :actions).menus.map(&:tag).include?(:settings)
  end

  test 'Menu for user should not include update' do
    assert_not freetown.menu(user_context, :actions).menus.map(&:tag).include?(:settings)
  end

  test 'Application menu for administrator should include hidden forum' do
    assert freetown
             .page
             .menu(administrator_context, :navigations)
             .menus
             .find { |f| f.tag == :forums }
             .menus
             .map(&:tag)
             .include?(:second)
  end

  test 'Application menu for user should not include hidden forum' do
    assert_not freetown
                 .page
                 .menu(user_context, :navigations)
                 .menus
                 .find { |f| f.tag == :forums }
                 .menus
                 .map(&:tag)
                 .include?(:second)
  end

  test 'Include custom menu items' do
    assert_equal(
      'Custom label',
      freetown
        .page
        .menu(user_context, :navigations)
        .menus
        .find { |f| f.tag == "custom_#{custom_menu_item.id}" }
        .label
    )
  end

  test 'Do not include custom menu items if other page' do
    assert_nil(
      create(:page)
        .menu(user_context, :navigations)
        .menus
        .find { |f| f.tag == "custom_#{custom_menu_item.id}" }
    )
  end
end
