# frozen_string_literal: true
require 'test_helper'

class VoteTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:user) { create(:user) }
  subject { create(:vote, parent: motion.edge) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  def test_duplicate_constraint
    assert_raises ActiveRecord::RecordNotUnique do
      Vote.transaction do
        Vote.create(
          edge: motion.edge.children.new(user: user),
          voteable: motion,
          voter: user.profile,
          forum: motion.forum,
          publisher: user)
        Vote.create(
          edge: motion.edge.children.new(user: user),
          voteable: motion,
          voter: user.profile,
          forum: motion.forum,
          publisher: user)
        assert motion.edge.save, motion.edge.errors.full_messages
      end
    end
  end
end
