# frozen_string_literal: true

require 'test_helper'

class PollTest < ActiveSupport::TestCase
  define_freetown
  subject { create(:poll, parent: freetown) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
