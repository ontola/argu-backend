require 'test_helper'

class VotesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:freetown) { create(:forum, name: :freetown) }
  let(:motion) { create(:motion, forum: freetown) }
  let!(:vote) { create(:vote, voteable: motion) }

  ####################################
  # As Guest
  ####################################

  test 'guest shoud not get new' do
    get :new, motion_id: motion

    assert_redirected_to new_user_session_path(
      r: new_motion_vote_path(
        vote: {for: nil},
        confirm: true))
    assert_not assigns(:model)
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test "should not delete destroy others' vote" do
    sign_in user

    vote # Trigger
    assert_no_difference('Vote.count') do
      delete :destroy, id: vote.id, format: :json
    end

    assert_response 403
  end

  test 'should 403 when not a member' do
    sign_in user

    post :create,
         motion_id: motion,
         for: :pro,
         format: :json

    assert_response 403
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member shoud get new' do
    sign_in member

    get :new, motion_id: motion

    assert_response 200
    assert assigns(:model)
  end

  test 'should post create' do
    sign_in member

    assert_difference('Vote.count', 1) do
      post :create,
           motion_id: motion,
           for: :pro,
           format: :json
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:vote)
  end

  test 'should not create new vote when existing one is present' do
    create(:vote,
           voteable: motion,
           voter: member.profile,
           for: 'neutral')
    sign_in member

    assert_no_difference('Vote.count') do
      post :create,
           motion_id: motion,
           vote: {
             for: 'neutral'
           },
           format: :json
    end

    assert_response 304
    assert assigns(:model)
    assert assigns(:vote)
  end

  test 'should delete destroy own vote' do
    vote = create(:vote,
                  voteable: motion,
                  voter: member.profile,
                  for: 'neutral')
    sign_in member

    assert_difference('Vote.count', -1) do
      delete :destroy,
             id: vote.id,
             format: :json
    end

    assert_response 204
  end
end
