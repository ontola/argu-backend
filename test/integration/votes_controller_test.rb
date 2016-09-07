# frozen_string_literal: true
require 'test_helper'

class VotesControllerTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let!(:vote) { create(:vote, parent: motion.edge) }

  ####################################
  # As Guest
  ####################################

  test 'guest shoud not get new' do
    get new_motion_vote_path(motion)

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
      delete vote_path(vote.id), params: {format: :json}
    end

    assert_response 403
  end

  test 'should 403 when not a member' do
    sign_in user

    post motion_votes_path(motion),
         params: {
           for: :pro,
           format: :json
         }

    assert_response 403
  end

  test 'should 403 when not a member json_api' do
    sign_in user

    post votes_path,
         params: {
           format: :json_api,
           data: {
             type: 'votes',
             attributes: {
               for: :pro
             },
             relationships: {
               parent: {
                 data: {
                   type: 'motions',
                   id: motion.id
                 }
               }
             }
           }
         }

    assert_response 403
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member shoud get new' do
    sign_in member

    get new_motion_vote_path(motion)

    assert_response 200
    assert assigns(:model)
  end

  test 'should post create' do
    sign_in member

    assert_differences([['Vote.count', 1], ['Edge.count', 1]]) do
      post motion_votes_path(motion),
           params: {
             for: :pro,
             format: :json
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert_analytics_collected('votes', 'create', 'pro')
  end

  test 'should post create json_api' do
    sign_in member

    assert_differences([['Vote.count', 1], ['Edge.count', 1]]) do
      post votes_path,
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
               },
               relationships: {
                 parent: {
                   data: {
                     type: 'motions',
                     id: motion.id
                   }
                 }
               }
             }
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.pro?
  end

  test 'should not create new vote when existing one is present' do
    create(:vote,
           parent: motion.edge,
           voter: member.profile,
           options: {
            publisher: member,
            owner: member.profile
           },
           for: 'neutral')
    sign_in member

    assert_no_difference('Vote.count') do
      post motion_votes_path(motion),
           params: {
             vote: {
               for: 'neutral'
             },
             format: :json
           }
    end

    assert_response 304
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
  end

  test 'should not create new vote when existing one is present json_api' do
    create(:vote,
           parent: motion.edge,
           voter: member.profile,
           options: {
            publisher: member,
            owner: member.profile
           },
           for: 'neutral')
    sign_in member

    assert_no_difference('Vote.count') do
      post votes_path,
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :neutral
               },
               relationships: {
                 parent: {
                   data: {
                     type: 'motions',
                     id: motion.id
                   }
                 }
               }
             }
           }
    end

    assert_response 304
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.neutral?
  end

  test 'should not create new vote when existing one is present with html' do
    create(:vote,
           parent: motion.edge,
           voter: member.profile,
           options: {
             publisher: member,
             owner: member.profile
           },
           for: 'neutral')
    sign_in member

    assert_no_difference('Vote.count') do
      post motion_votes_path(motion),
           params: {
             vote: {
               for: 'neutral'
             }
           }
    end

    assert_redirected_to motion_path(motion)
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
  end

  test 'should update vote when existing one is present' do
    create(:vote,
           parent: motion.edge,
           voter: member.profile,
           options: {
             publisher: member,
             owner: member.profile
           },
           for: 'neutral')
    sign_in member

    assert_no_difference('Vote.count') do
      post motion_votes_path(motion),
           params: {
             vote: {
               for: 'pro'
             },
             format: :json
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert_analytics_collected('votes', 'update', 'pro')
  end

  test 'should update vote when existing one is present json_api' do
    create(:vote,
           parent: motion.edge,
           voter: member.profile,
           options: {
             publisher: member,
             owner: member.profile
           },
           for: 'neutral')
    sign_in member

    assert_no_difference('Vote.count') do
      post votes_path,
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
               },
               relationships: {
                 parent: {
                   data: {
                     type: 'motions',
                     id: motion.id
                   }
                 }
               }
             }
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.pro?
  end

  test 'should delete destroy own vote' do
    member_vote = create(:vote,
                         parent: motion.edge,
                         options: {
                           creator: member.profile
                         },
                         for: 'neutral')
    sign_in member

    assert_differences([['Vote.count', -1], ['Edge.count', -1]]) do
      delete vote_path(member_vote), params: {format: :json}
    end

    assert_response 204
    assert_analytics_collected('votes', 'destroy', 'neutral')
  end
end
