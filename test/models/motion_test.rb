require 'test_helper'

class MotionTest < ActiveSupport::TestCase

  def motion
    @motions ||= motions(:one)
  end

  def test_valid
    assert motion.valid?, motion.errors.to_a.join(',').to_s
  end

  test 'top_arguments_con_light should not include trashed motions' do
    assert_not motion.top_arguments_con_light.map { |i| i[0] }.include?(arguments(:trashed_con).id)
  end

  test 'top_arguments_pro_light should not include trashed motions' do
    assert_not motion.top_arguments_con_light.map { |i| i[0] }.include?(arguments(:trashed).id)
  end
end
