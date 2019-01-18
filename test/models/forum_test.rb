# frozen_string_literal: true

require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  include ModelTestBase

  define_cairo
  define_holland('subject')
  define_cairo('cairo2')
  define_cairo('youngbelegen')

  let(:page) { create_page }
  let(:group) { create(:group, parent: page) }
  let(:user) { create(:user) }
  let(:forum) do
    create(:forum, parent: page, url: 'new_forum', locale: 'nl')
  end

  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'default decision group' do
    group
    assert forum.default_decision_group.grants.administrator.present?
  end

  test 'should reset public grant' do
    assert_equal subject.grants.where(group_id: -1).count, 1
    subject.update(public_grant: 'none')
    assert_equal subject.grants.where(group_id: -1).count, 0

    assert_equal cairo.grants.where(group_id: -1).count, 0
    cairo.update(public_grant: 'participator')
    assert_equal cairo.grants.where(group_id: -1).count, 1
  end

  test 'display_name should work' do
    assert_equal subject.name, subject.display_name
  end

  test 'description should work' do
    assert_equal subject.description, subject.bio
  end

  test 'enforce hide last_name for youngbelegen' do
    assert_equal user.hide_last_name, false
    create(:motion, publisher: user, parent: cairo)
    assert_equal user.reload.hide_last_name, false
    create(:motion, publisher: user, parent: youngbelegen)
    assert_equal user.reload.hide_last_name, true
  end
end
