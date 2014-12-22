require "test_helper"

class ForumTest < ActiveSupport::TestCase

  def forum
    @forum ||= forums(:utrecht)
  end

  def test_valid
    assert forum.valid?, forum.errors.to_a.join(',').to_s
  end

end
