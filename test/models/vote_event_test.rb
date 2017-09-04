# frozen_string_literal: true

require 'test_helper'

class VoteEventTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:subject) { motion.default_vote_event }

  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
