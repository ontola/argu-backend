require 'test_helper'

class VoteTest < ActiveSupport::TestCase
  subject { create(:vote) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
