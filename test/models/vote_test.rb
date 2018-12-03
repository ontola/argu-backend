# frozen_string_literal: true

require 'test_helper'

class VoteTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }
  let(:user) { create(:user) }
  subject { create(:vote, parent: motion.default_vote_event) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  def test_duplicate_constraint # rubocop:disable Metrics/AbcSize
    first = create_vote
    second = create_vote
    assert motion.save, motion.errors.full_messages
    assert_not first.reload.primary?
    assert second.reload.primary?
    assert_raises ActiveRecord::RecordNotUnique do
      Vote.where(id: [first.id, second.id]).update_all(primary: true)
    end
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
