require 'test_helper'

class MotionTest < ActiveSupport::TestCase

  def motion
    @motions ||= motions(:one)
  end

  def test_valid
    assert motion.valid?, motion.errors.to_a.join(',').to_s
  end

  test 'top_arguments_con should not include trashed motions' do
    assert_not motion.top_arguments_con.include?(arguments(:trashed_con))
  end

  test 'top_arguments_pro should not include trashed motions' do
    assert_not motion.top_arguments_con.include?(arguments(:trashed))
  end
end
