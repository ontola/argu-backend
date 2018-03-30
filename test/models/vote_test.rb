# frozen_string_literal: true

require 'test_helper'

class VoteTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:user) { create(:user) }
  subject { create(:vote, parent: motion.default_vote_event.edge) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  def test_duplicate_constraint
    first = create_vote
    second = create_vote
    assert motion.edge.save, motion.edge.errors.full_messages
    assert_raises ActiveRecord::RecordNotUnique do
      Vote.where(id: [first.id, second.id]).update_all(primary: true)
    end
  end

  private

  def create_vote
    Vote.create!(
      edge: motion.default_vote_event.edge.children.new(user: user),
      voteable_id: motion.id,
      voteable_type: 'Motion',
      creator: user.profile,
      forum: motion.forum,
      publisher: user
    )
  end
end
