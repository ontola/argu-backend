# frozen_string_literal: true
require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  include ModelTestBase

  define_cairo
  define_holland('subject')
  define_venice
  define_cairo('cairo2')

  let(:user) { create(:user) }
  let(:subject_member) { create_member(subject) }

  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'should not leak access_token if disabled' do
    assert_equal false, subject.visible_with_a_link?
    assert_equal nil, subject.access_token, 'access tokens are returned if turned off'
    assert_not_equal nil, subject.access_token!, 'test is useless since forum has no access_token'
  end

  test 'should return access_token if enabled' do
    assert venice.visible_with_a_link?
    assert_not_equal nil, venice.access_token
    assert_not_equal nil, venice.access_token!
  end

  test 'access token functions return correct type' do
    assert venice.access_token.is_a?(String)
    assert venice.access_token!.is_a?(String)
    assert venice.full_access_token.is_a?(AccessToken)
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

  test 'first_public should return a public forum' do
    forum = Forum.first_public
    assert forum.open?
  end

  test 'profile_is_member should function correctly' do
    assert_not subject.profile_is_member?(user.profile)
    assert subject.profile_is_member?(subject_member.profile)
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
