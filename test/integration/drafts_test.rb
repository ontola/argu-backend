# frozen_string_literal: true

require 'test_helper'

class DraftsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:staff) { create(:user, :staff) }
  let!(:question) { create(:question, parent: freetown) }
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

  test 'user should post published motion' do
    sign_in user

    assert_difference(
      'Motion.count' => 1,
      'Motion.published.count' => 1,
      'Notification.drafts_reminder.count' => 0
    ) do
      Sidekiq::Testing.inline! do
        post question.collection_iri(:motions),
             headers: argu_headers(accept: :nq),
             params: {motion: {title: 'new draft', content: 'motion content', is_draft: false}}
        assert_response :created
      end
    end
  end

  test 'user should post new draft motion' do
    sign_in other_user

    assert_difference(
      'Motion.count' => 1,
      'Motion.published.count' => 0,
      'Notification.drafts_reminder.count' => 1
    ) do
      Sidekiq::Testing.inline! do
        post freetown.collection_iri(:motions),
             headers: argu_headers(accept: :nq),
             params: {motion: {title: 'new draft', content: 'motion content', is_draft: true}}
        assert_response :created
      end
    end

    create_email_mock('drafts_reminder', other_user.email, drafts_url: drafts_iri)

    Sidekiq::Testing.inline! do
      # rubocop:disable Rails/SkipsModelValidations
      Notification
        .where.not(notification_type: Notification.notification_types[:drafts_reminder], user: other_user)
        .update_all(read_at: Time.current)
      # rubocop:enable Rails/SkipsModelValidations
      travel 2.days do
        DirectNotificationsSchedulerWorker.new.perform
      end
    end

    assert_email_sent(skip_sidekiq: true)
  end

  test 'user should publish existing draft with draft=false' do
    sign_in user
    assert_nil motion.argu_publication.published_at
    assert_not motion.is_published?
    Sidekiq::Testing.inline! do
      assert_difference('Notification.drafts_reminder.count' => -1) do
        put update_path(motion),
            headers: argu_headers,
            params: {motion: {argu_publication_attributes: {draft: 'false'}}}
      end
    end
    assert_not_nil motion.argu_publication.reload.published_at
    assert motion.reload.is_published?
  end

  test 'user should publish existing draft with published_at' do
    sign_in user
    assert_nil motion.argu_publication.published_at
    assert_not motion.is_published?
    Sidekiq::Testing.inline! do
      assert_difference('Notification.drafts_reminder.count' => -1) do
        put update_path(motion),
            headers: argu_headers,
            params: {motion: {argu_publication_attributes: {published_at: Time.current}}}
      end
    end
    assert_not_nil motion.argu_publication.reload.published_at
    assert motion.reload.is_published?
  end

  test 'user should not publish existing draft with draft=true' do
    sign_in user
    assert_nil motion.argu_publication.published_at
    assert_not motion.is_published?
    Sidekiq::Testing.inline! do
      assert_difference('Notification.drafts_reminder.count' => 0) do
        put update_path(motion),
            headers: argu_headers,
            params: {motion: {argu_publication_attributes: {draft: 'true'}}}
      end
    end
    assert_nil motion.argu_publication.reload.published_at
    assert_not motion.reload.is_published?
  end

  test 'user should not publish existing draft without draft' do
    sign_in user
    assert_nil motion.argu_publication.published_at
    assert_not motion.is_published?
    Sidekiq::Testing.inline! do
      assert_difference('Notification.drafts_reminder.count' => 0) do
        put update_path(motion),
            headers: argu_headers,
            params: {motion: {display_name: 'new title'}}
      end
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
