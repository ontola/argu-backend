# frozen_string_literal: true

require 'test_helper'

class RedirectssTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:question) { create(:question, owner_id: 1, parent: freetown) }
  let(:motion) { create(:motion, owner_id: 1, parent: freetown) }
  let(:pro_argument) { create(:argument, owner_id: 1, parent: motion) }
  let(:con_argument) { create(:argument, owner_id: 2, parent: motion, pro: false) }
  let(:comment) { create(:comment, owner_id: 1, parent: motion) }
  let(:blog_post) do
    create(:blog_post, owner_id: 1, parent: motion)
  end
  let(:decision) do
    create(
      :decision,
      owner_id: 1,
      parent: motion,
      state: 'approved'
    )
  end
  let(:group) { Group.custom.first }
  let(:group_membership) { create(:group_membership, parent: group) }

  before do
    ActsAsTenant.current_tenant = nil
  end

  #####################################################
  # Unscoped routes
  #####################################################

  test 'redirect unscoped forum route' do
    get argu_url("/#{freetown.url}")
    assert_redirected_to resource_iri(freetown).path
  end

  test 'redirect unscoped question route' do
    get argu_url("/q/#{question.fragment}")
    assert_redirected_to resource_iri(question).path
  end

  test 'redirect unscoped motion route' do
    get argu_url("/m/#{motion.fragment}")
    assert_redirected_to resource_iri(motion).path
  end

  test 'redirect unscoped argument route' do
    get argu_url("/a/#{pro_argument.fragment}")
    assert_redirected_to resource_iri(pro_argument).path
  end

  test 'redirect unscoped pro_argument route' do
    get argu_url("/pro/#{pro_argument.fragment}")
    assert_redirected_to resource_iri(pro_argument).path
  end

  test 'redirect unscoped con_argument route' do
    get argu_url("/con/#{con_argument.fragment}")
    assert_redirected_to resource_iri(con_argument).path
  end

  test 'redirect unscoped blog_post route' do
    get argu_url("/posts/#{blog_post.fragment}")
    assert_redirected_to resource_iri(blog_post).path
  end

  test 'redirect unscoped comment route' do
    get argu_url("/c/#{comment.fragment}")
    assert_redirected_to resource_iri(comment).path
  end

  test 'redirect unscoped decision route' do
    get argu_url("/m/#{motion.fragment}/decision/#{decision.step}")
    assert_redirected_to resource_iri(decision).path
  end

  test 'redirect unscoped group_membership route' do
    get argu_url("/group_memberships/#{group_membership.id}")
    assert_redirected_to resource_iri(group_membership).path
  end
end
