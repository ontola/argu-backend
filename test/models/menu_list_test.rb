# frozen_string_literal: true

require 'test_helper'

class MenuListTest < ActiveSupport::TestCase
  define_freetown
  define_freetown('second', attributes: {initial_public_grant: nil})
  let(:other_page) { create_page }

  let(:user) { create(:user) }
  let(:user_context) do
    UserContext.new(
      profile: user.profile,
      user: user
    )
  end
  let(:other_page_context) do
    UserContext.new(
      profile: user.profile,
      user: user
    )
  end

  let(:administrator) { create_administrator(argu) }
  let(:administrator_context) do
    UserContext.new(
      profile: administrator.profile,
      user: administrator
    )
  end

  let!(:custom_menu_item) do
    CustomMenuItem.create(
      menu_type: 'navigations',
      resource_type: 'Edge',
      resource_id: argu.uuid,
      label: 'Custom label',
      href: 'https://argu.localdev/i/about',
      icon: 'fa-info'
    )
  end

  before do
    ActsAsTenant.current_tenant = argu
  end

  test 'Menu for administrator should include update' do
    assert freetown.menu(:actions, administrator_context).menus.compact.map(&:tag).include?(:edit)
  end

  test 'Menu for user should not include update' do
    assert_equal freetown.menu(:actions, user_context).menus.compact.map(&:tag), %i[activity search copy]
  end

  test 'Page menu for administrator should include hidden forum' do
    assert argu.menu(:navigations, administrator_context).menus.compact.map(&:href).include?(second.iri)
  end

  test 'Page menu for user should not include hidden forum' do
    assert_not argu.menu(:navigations, user_context).menus.compact.map(&:href).include?(second.iri)
  end

  test 'Include custom menu items' do
    assert_equal(
      'Custom label',
      freetown
        .root
        .menu(:navigations, user_context)
        .menus
        .compact
        .find { |f| f == custom_menu_item }
        .label
    )
  end

  test 'Do not include custom menu items if other page' do
    ActsAsTenant.with_tenant(other_page) do
      assert_nil(
        other_page
          .menu(:navigations, other_page_context)
          .menus
          .compact
          .find { |f| f == custom_menu_item }
      )
    end
  end
end
