# frozen_string_literal: true
require 'test_helper'

class VoteEventTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:subject) { motion.default_vote_event }

  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'starts_at before ends_at' do
    subject.starts_at = DateTime.current
    assert subject.valid?, subject.errors.to_a.join(',').to_s
    subject.ends_at = 1.day.ago
    assert_not subject.valid?
    subject.ends_at = 1.day.from_now
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
