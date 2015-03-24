require "test_helper"

class ProfileTest < ActiveSupport::TestCase

  def profile
    @profile ||= profiles(:profile_one)
  end

  def test_valid
    assert profile.valid?, profile.errors.to_a.join(',').to_s
  end

  test "shortname valid" do
    assert_equal profile.url, 'user'
  end

  test "display_name valid" do
    assert_equal profile.display_name, 'User'
  end

  test "member_of? function" do
    assert profile.member_of?(forums(:utrecht)), 'false negative when forum is passed'
    assert_not profile.member_of?(forums(:amsterdam)), 'false positive when forum is passed'

    assert profile.member_of?(forums(:utrecht).id), 'false negative when forum_id is passed'
    assert_not profile.member_of?(forums(:amsterdam).id), 'false positive when forum_id is passed'
  end

end
