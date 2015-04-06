require 'test_helper'

class ActivityTest < ActiveSupport::TestCase

  def activity
    @activity ||= activities(:motion_one_create)
  end

  def test_valid
    assert activity.valid?
  end

end
