# frozen_string_literal: true

require 'test_helper'

class MarkAsImportantTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:marked_draft) do
    create(
      :motion,
      parent: freetown,
      mark_as_important: true,
      argu_publication_attributes: {draft: true}
    )
  end
  let(:unmarked_draft) do
    create(:motion, parent: freetown, argu_publication_attributes: {draft: true})
  end
  let(:marked_published) { create(:motion, parent: freetown, mark_as_important: true) }
  let(:unmarked_published) { create(:motion, parent: freetown) }
  let(:moderator) { create_moderator(freetown) }
  let!(:news_follow) { create(:news_follow, followable: freetown, follower: create_initiator(freetown)) }

  # New Motion
  test 'create with mark_as_important = 1' do
    assert_difference('Notification.count', 2) do
      create_motion('1', 'news')
    end
  end

  test 'create with mark_as_important = 0' do
    assert_difference('Notification.count', 1) do
      create_motion('0', 'reactions')
    end
  end

  test 'create with missing mark_as_important' do
    assert_difference('Notification.count', 1) do
      create_motion(nil, 'reactions')
    end
  end

  # Update marked draft
  test 'updated marked draft with mark_as_important = 1' do
    update_motion(marked_draft, '1', 'news')
  end

  test 'updated marked draft with mark_as_important = 0' do
    update_motion(marked_draft, '0', 'reactions')
  end

  test 'updated marked draft with missing mark_as_important' do
    update_motion(marked_draft, nil, 'news')
  end

  # Update unmarked draft
  test 'updated unmarked draft with mark_as_important = 1' do
    update_motion(unmarked_draft, '1', 'news')
  end

  test 'updated unmarked draft with mark_as_important = 0' do
    update_motion(unmarked_draft, '0', 'reactions')
  end

  test 'updated unmarked draft with missing mark_as_important' do
    update_motion(unmarked_draft, nil, 'reactions')
  end

  # Update marked published
  test 'updated marked published with mark_as_important = 1' do
    marked_published
    assert_difference('Notification.count', 0) do
      update_motion(marked_published, '1', 'news')
    end
  end

  test 'updated marked published with mark_as_important = 0' do
    marked_published
    assert_difference('Notification.count', 0) do
      update_motion(marked_published, '0', 'news')
    end
  end

  test 'updated marked published with missing mark_as_important' do
    marked_published
    assert_difference('Notification.count', 0) do
      update_motion(marked_published, nil, 'news')
    end
  end

  # Update unmarked published
  test 'updated unmarked published with mark_as_important = 1' do
    unmarked_published
    assert_difference('Notification.count', 1) do
      update_motion(unmarked_published, '1', 'news')
    end
  end

  test 'updated unmarked published with mark_as_important = 0' do
    unmarked_published
    assert_difference('Notification.count', 0) do
      update_motion(unmarked_published, '0', 'reactions')
    end
  end

  test 'updated unmarked published with missing mark_as_important' do
    unmarked_published
    assert_difference('Notification.count', 0) do
      update_motion(unmarked_published, nil, 'reactions')
    end
  end

  private

  def create_motion(mark, follow_type) # rubocop:disable Metrics/AbcSize
    sign_in moderator
    attributes = attributes_for(:motion)
    attributes[:mark_as_important] = mark unless mark.nil?

    assert_difference('Motion.count', 1) do
      post collection_iri(freetown, :motions), params: {motion: attributes}
    end
    ActsAsTenant.with_tenant(argu) { PublicationsWorker.drain }
    assert_equal Motion.last.argu_publication.follow_type, follow_type
  end

  def update_motion(motion, mark, follow_type)
    sign_in moderator
    attributes = {title: 'New title'}
    attributes[:mark_as_important] = mark unless mark.nil?

    put motion, params: {motion: attributes}

    ActsAsTenant.with_tenant(argu) { PublicationsWorker.drain }

    motion.reload
    assert_equal motion.title, 'New title'
    assert_equal motion.argu_publication.follow_type, follow_type
  end
end
