require 'test_helper'

class VoteTest < ActiveSupport::TestCase
  subject { FactoryGirl.create(:vote) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
