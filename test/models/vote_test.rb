# frozen_string_literal: true

require 'test_helper'

class VoteTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }
  let(:user) { create(:user) }
  subject { create(:vote, parent: motion.default_vote_event) }
  let(:vote_with_comment) { create(:vote, parent: motion.default_vote_event) }
  let(:comment) { create(:comment, parent: motion.default_vote_event, vote: vote_with_comment, description: 'Opinion') }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  def test_duplicate_constraint # rubocop:disable Metrics/AbcSize
    ActsAsTenant.current_tenant = motion.root
    first = create_vote
    second = create_vote
    assert motion.save, motion.errors.full_messages
    assert_not first.reload.primary?
    assert second.reload.primary?
    assert_raises ActiveRecord::RecordNotUnique do
      Vote.where(id: [first.id, second.id]).update_all(primary: true)
    end
  end

  test 'preloaded comment has description' do
    assert_equal comment.description, vote_with_comment.comment.description
    assert_equal(
      comment.description,
      Vote.where(id: vote_with_comment.id).includes(Vote.includes_for_serializer).first.comment.description
    )
  end

  private

  def create_vote
    Vote.create!(
      parent: motion.default_vote_event,
      creator: user.profile,
      publisher: user,
      root_id: motion.default_vote_event.root_id
    )
  end
end
