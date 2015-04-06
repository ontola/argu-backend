require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def user
    @user ||= users(:user)
  end

  def test_valid
    assert user.valid?, user.errors.to_a.join(',').to_s
  end

end
