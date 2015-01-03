require "test_helper"

class VoteTest < ActiveSupport::TestCase

  def vote
    @vote ||= votes(:one)
  end

  def test_valid
    assert vote.valid?, vote.errors.to_a.join(',').to_s
  end

end
