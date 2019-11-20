# frozen_string_literal: true

require 'test_helper'

class DraftsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }
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
           argu_publication_attributes: {draft: true})
  end

  before do
    ActsAsTenant.current_tenant = argu
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should not get index' do
    get drafts_user_path(user)
    assert_not_a_user
    assert_response 302
  end

  ####################################
  # As User
  ####################################
  let(:other_user) { create(:user) }

  test 'user should not get index other' do
    sign_in other_user
    get drafts_user_path(user)
    assert_not_authorized
    assert_response 403
    assert_select '.draft', 0
  end

  test 'user should get index' do
    sign_in user
    get drafts_user_path(user)
    assert 200
    assert_select '.draft', 1
  end

  test 'user should get index nq' do
    sign_in user, Doorkeeper::Application.argu_front_end
    get "/#{argu.url}#{drafts_user_path(user)}", headers: argu_headers(accept: :nq)
    assert 200
    expect_triple(collection_iri(user, :drafts, root: argu), NS::AS[:totalItems], 1, NS::ONTOLA[:replace])
  end

  test 'user should publish draft with draft=false' do
    sign_in user, Doorkeeper::Application.argu_front_end
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
    sign_in user, Doorkeeper::Application.argu_front_end
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
    sign_in user, Doorkeeper::Application.argu_front_end
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
    sign_in user, Doorkeeper::Application.argu_front_end
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
    create(:group_membership, parent: group, shortname: user.url)
    create(:grant, edge: argu, group: group, grant_set: GrantSet.administrator)
    sign_in user
    get drafts_user_path(user)
    assert 200
    assert_select '.draft', 2
  end

  test 'administrator should get index nq' do
    group = create(:group, parent: argu)
    create(:group_membership, parent: group, shortname: user.url)
    create(:grant, edge: argu, group: group, grant_set: GrantSet.administrator)
    sign_in user, Doorkeeper::Application.argu_front_end
    get "/#{argu.url}#{drafts_user_path(user)}", headers: argu_headers(accept: :nq)
    assert 200
    expect_triple(collection_iri(user, :drafts, root: argu), NS::AS[:totalItems], 2, NS::ONTOLA[:replace])
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should get index' do
    sign_in staff
    get drafts_user_path(user)
    assert 200
    assert_select '.draft', 1
  end

  test 'staff should get index nq' do
    sign_in staff, Doorkeeper::Application.argu_front_end
    get "/#{argu.url}#{drafts_user_path(user)}", headers: argu_headers(accept: :nq)
    assert 200
    expect_triple(collection_iri(user, :drafts, root: argu), NS::AS[:totalItems], 1, NS::ONTOLA[:replace])
  end
end
