# frozen_string_literal: true
require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  include ModelTestBase

  define_cairo
  define_holland('subject')
  define_cairo('cairo2')

  let(:user) { create(:user) }
  let(:subject_member) { create_member(subject) }

  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'should reset public grant' do
    assert_equal subject.grants.where(group_id: -1).count, 1
    subject.update(public_grant: 'none')
    assert_equal subject.grants.where(group_id: -1).count, 0

    assert_equal cairo.grants.where(group_id: -1).count, 0
    cairo.update(public_grant: 'member')
    assert_equal cairo.grants.where(group_id: -1).count, 1
  end

  test 'display_name should work' do
    assert_equal subject.name, subject.display_name
  end

  test 'description should work' do
    assert_equal subject.description, subject.bio
  end

  test 'page should accept page or url' do
    p1 = create(:page)
    assert p1.id != subject.page.id
    subject.page = p1
    assert_equal p1.id, subject.page.id

    p2 = create(:page)
    assert p2.id != subject.page.id
    subject.page = p2.url
    assert_equal p2.id, subject.page.id
  end

  define_holland('shortname_forum', attributes: {max_shortname_count: 0})
  test 'shortnames_depleted? should function correctly' do
    f = shortname_forum
    assert_equal true,
                 f.shortnames_depleted?,
                 'zero shortname allowance false negative'

    f.max_shortname_count = 1
    assert_equal false,
                 f.shortnames_depleted?,
                 'in bound shortname allowance false positive'

    m = create(:motion, parent: subject.edge)
    create(:shortname,
           forum: m.forum,
           owner: m)
    assert_equal false,
                 f.shortnames_depleted?,
                 'external shortname creation cross-affects tenants'

    s = create(:shortname,
               forum: f,
               owner: f.motions.first)
    assert_equal true,
                 f.shortnames_depleted?,
                 "shortname count doesn't affect limit"

    s.destroy
    assert_equal false,
                 f.shortnames_depleted?,
                 "shortname destruction doesn't free limit"
  end
end
