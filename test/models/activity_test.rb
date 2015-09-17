require 'test_helper'

class ActivityTest < ActiveSupport::TestCase

  subject { FactoryGirl.create(:activity) }

  def test_valid
    assert subject.valid?
  end

end
