# frozen_string_literal: true

require 'test_helper'

class MenuListTest < ActiveSupport::TestCase
  define_freetown
  define_freetown('second', attributes: {public_grant: 'none'})

  let(:user) { create(:user) }
  let(:user_context) { UserContext.new(user, user.profile, {}) }

  let(:administrator) { create_administrator(freetown.page) }
  let(:administrator_context) { UserContext.new(administrator, administrator.profile, {}) }

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
end
