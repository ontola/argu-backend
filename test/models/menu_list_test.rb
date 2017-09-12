# frozen_string_literal: true

require 'test_helper'

class MenuListTest < ActiveSupport::TestCase
  define_freetown
  define_freetown('second', attributes: {public_grant: 'none'})

  let(:user) { create(:user) }
  let(:user_context) { UserContext.new(user, user.profile, {}) }

  let(:super_admin) { create_super_admin(freetown.page) }
  let(:super_admin_context) { UserContext.new(super_admin, super_admin.profile, {}) }

  test 'Menu for super admin should include update' do
    assert freetown.menu(super_admin_context, :actions).menus.map(&:tag).include?(:settings)
  end

  test 'Menu for user should not include update' do
    assert_not freetown.menu(user_context, :actions).menus.map(&:tag).include?(:settings)
  end

  test 'Application menu for super admin should include hidden forum' do
    assert freetown.page.menu(super_admin_context, :navigations).menus.map(&:tag).include?(:second)
  end

  test 'Application menu for user should not include hidden forum' do
    assert_not freetown.page.menu(user_context, :navigations).menus.map(&:tag).include?(:second)
  end
end
