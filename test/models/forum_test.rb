# frozen_string_literal: true

require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  include ModelTestBase

  define_cairo
  define_holland('subject', attributes: {bio: 'test_bio'})
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

  test 'display_name should work' do
    assert_equal subject.name, subject.display_name
  end

  test 'description should work' do
    assert_equal subject.description, subject.bio
  end
end
