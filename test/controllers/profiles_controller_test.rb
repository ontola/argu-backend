require "test_helper"

class ProfilesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get show" do
    sign_in users(:user)

    get :show, id: profiles(:profile_two).username

    assert_response :success
    assert_not_nil assigns(:profile)
    assert_not_nil assigns(:collection)

    _memberships = assigns(:current_profile).memberships.map(&:forum_id)
    assert assigns(:collection).values.all? { |arr| arr[:collection].all? { |v| _memberships.include?(v.forum_id) || v.forum.open? } }, "Votes of closed fora are visible to non-members"
  end


end
