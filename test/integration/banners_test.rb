# frozen_string_literal: true

require 'test_helper'

class BannersTest < ActionDispatch::IntegrationTest
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
    define_test(hash, :new, options: {parent: :freetown}) do
      user_types[:new].merge(
        user: exp_res(asserts: [assert_not_authorized]),
        member: exp_res(asserts: [assert_not_authorized]),
        manager: exp_res(asserts: [assert_not_authorized])
      )
    end
    define_test(hash, :create, options: {parent: :freetown}) do
      user_types[:create].merge(
        user: exp_res(asserts: [assert_not_authorized]),
        member: exp_res(asserts: [assert_not_authorized]),
        manager: exp_res(asserts: [assert_not_authorized])
      )
    end
    define_test(hash, :edit) do
      user_types[:edit].merge(manager: exp_res(asserts: [assert_not_authorized])).except(:creator)
    end
    define_test(hash, :update) do
      user_types[:update].merge(manager: exp_res(asserts: [assert_not_authorized])).except(:creator)
    end
    define_test(hash, :destroy) do
      user_types[:destroy]
        .merge(manager: exp_res(asserts: [assert_not_authorized]), super_admin: exp_res(should: true, response: 303))
        .except(:creator)
    end
  end
end
