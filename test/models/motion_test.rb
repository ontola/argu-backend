require "test_helper"

class MotionTest < ActiveSupport::TestCase

  def motion
    @motions ||= motions(:one)
  end

  def test_valid
    assert motion.valid?, motion.errors.to_a.join(',').to_s
  end

end
