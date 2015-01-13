require "test_helper"

class ProfilesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get show" do
    sign_in users(:user)

    get :show, id: profiles(:profile_two).username

    assert_response :success
    assert_not_nil assigns(:profile)
    assert_not_nil assigns(:collection)

    _memberships = assigns(:current_profile).memberships.pluck(:forum_id)
    assert assigns(:collection).values.all? { |arr| arr[:collection].all? { |v| _memberships.include?(v.forum_id) || v.forum.open? } }, "Votes of closed fora are visible to non-members"
  end

  test "should not show all votes" do
    sign_in users(:user2)

    get :show, id: profiles(:profile_two).username
    assert_response 200
    assert assigns(:collection)

    assert_not assigns(:collection)[:con][:collection].any?, "all votes are shown"
    assert_equal profiles(:profile_two).votes_questions_motions.length, assigns(:collection).values.map {|i| i[:collection].length }.inject(&:+), "Not all/too many votes are shown"
  end


end
