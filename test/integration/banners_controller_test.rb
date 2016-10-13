# frozen_string_literal: true
require 'test_helper'

class BannersControllerTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let(:subject) do
    create(:banner,
           audience: Banner.audiences[:everyone],
           forum: freetown,
           title: 'title',
           content: 'content')
  end

  def edit_path(record)
    url_for([:edit, record.forum, record])
  end

  def update_path(record)
    url_for([record.forum, record])
  end

  def destroy_path(record)
    url_for([record.forum, record])
  end

  define_tests do
    hash = {}
    define_test(hash, :new, options: {parent: :freetown}, user_types: user_types[:new].merge(
      member: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      moderator: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']}
    ))
    define_test(hash, :create, options: {parent: :freetown}, user_types: user_types[:create].merge(
      member: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      moderator: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']}
    ))
    define_test(hash, :edit, user_types: user_types[:edit].except(:creator))
    define_test(hash, :update, user_types: user_types[:update].except(:creator))
    define_test(hash, :destroy)
  end
end
