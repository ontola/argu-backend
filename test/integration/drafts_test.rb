# frozen_string_literal: true

require 'test_helper'

class DraftsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }
  let(:staff) { create(:user, :staff) }
  let!(:motion) do
    create(:motion,
           parent: freetown,
           publisher: user,
           argu_publication_attributes: {draft: true})
  end
  let!(:other_motion) do
    create(:motion,
           parent: freetown,
           argu_publication_attributes: {draft: true})
  end
  let!(:page_motion) do
    create(:motion,
           parent: freetown,
           creator: argu.profile,
           publisher: argu.publisher,
           argu_publication_attributes: {draft: true})
  end

  before do
    ActsAsTenant.current_tenant = argu
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should not get index' do
    sign_in :guest_user

    get drafts_iri
    assert 200
    expect_triple(drafts_iri, NS.as[:totalItems], 0, NS.ontola[:replace])
    expect_triple(drafts_iri, NS.as[:name], 'My drafts', NS.ontola[:replace])
  end

  ####################################
  # As User
  ####################################
  let(:other_user) { create(:user) }

  test 'user should get index' do
    sign_in user
    get drafts_iri
    assert 200
    expect_triple(drafts_iri, NS.as[:totalItems], 1, NS.ontola[:replace])
    expect_triple(drafts_iri, NS.as[:name], 'My drafts', NS.ontola[:replace])
  end

  test 'user should publish draft with draft=false' do
    sign_in user
    assert_nil motion.argu_publication.published_at
    assert_not motion.is_published?
    Sidekiq::Testing.inline! do
      patch update_path(motion),
            headers: argu_headers,
            params: {motion: {argu_publication_attributes: {draft: 'false'}}}
    end
    assert_not_nil motion.argu_publication.reload.published_at
    assert motion.reload.is_published?
  end

  test 'user should publish draft with published_at' do
    sign_in user
    assert_nil motion.argu_publication.published_at
    assert_not motion.is_published?
    Sidekiq::Testing.inline! do
      patch update_path(motion),
            headers: argu_headers,
            params: {motion: {argu_publication_attributes: {published_at: Time.current}}}
    end
    assert_not_nil motion.argu_publication.reload.published_at
    assert motion.reload.is_published?
  end

  test 'user should not publish draft with draft=true' do
    sign_in user
    assert_nil motion.argu_publication.published_at
    assert_not motion.is_published?
    Sidekiq::Testing.inline! do
      patch update_path(motion),
            headers: argu_headers,
            params: {motion: {argu_publication_attributes: {draft: 'true'}}}
    end
    assert_nil motion.argu_publication.reload.published_at
    assert_not motion.reload.is_published?
  end

  test 'user should not publish draft without draft' do
    sign_in user
    assert_nil motion.argu_publication.published_at
    assert_not motion.is_published?
    Sidekiq::Testing.inline! do
      patch update_path(motion),
            headers: argu_headers,
            params: {motion: {display_name: 'new title'}}
    end
    assert_equal motion.reload.title, 'New title'
    assert_nil motion.argu_publication.reload.published_at
    assert_not motion.reload.is_published?
  end

  ####################################
  # As administrator
  ####################################
  test 'administrator should get index' do
    group = create(:group, parent: argu)
    create(:group_membership, parent: group, member: user.profile)
    create(:grant, edge: argu, group: group, grant_set: GrantSet.administrator)
    sign_in user
    get drafts_iri
    assert 200
    expect_triple(drafts_iri, NS.as[:totalItems], 2, NS.ontola[:replace])
  end

  ####################################
  # As Staff
  ####################################
  test 'staff should get index' do
    sign_in staff
    get drafts_iri
    assert 200
    expect_triple(drafts_iri, NS.as[:totalItems], 1, NS.ontola[:replace])
  end

  private

  def drafts_iri
    ActsAsTenant.with_tenant(argu) { super }
  end
end
