# frozen_string_literal: true
require 'test_helper'

class VotesControllerTest < ActionDispatch::IntegrationTest
  define_freetown
  define_cairo
  let(:closed_question) { create(:question, expires_at: 1.day.ago, parent: freetown.edge) }
  let(:closed_question_motion) { create(:motion, parent: closed_question.edge) }
  let(:closed_question_argument) { create(:argument, parent: closed_question_motion.edge) }
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:argument) { create(:argument, parent: motion.edge) }
  let!(:vote) { create(:vote, parent: motion.edge) }
  let(:cairo_motion) { create(:motion, parent: cairo.edge) }
  let!(:cairo_vote) { create(:vote, parent: cairo_motion.edge) }

  ####################################
  # As Guest
  ####################################

  test 'guest should not get new' do
    get new_motion_vote_path(motion)

    assert_redirected_to new_user_session_path(r: new_motion_vote_path(confirm: true))
    assert_not assigns(:model)
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test "user should not delete destroy others' vote" do
    sign_in user

    vote # Trigger
    assert_no_difference('Vote.count') do
      delete vote_path(vote.id), params: {format: :json}
    end

    assert_response 403
  end

  test 'user shoud get new' do
    sign_in user

    get new_motion_vote_path(motion)

    assert_response 200
    assert assigns(:model)
  end

  test 'user should post create for motion' do
    sign_in user

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

  test 'user should post create for argument' do
    sign_in user
    argument

    assert_differences([['Vote.count', 1], ['Edge.count', 1]]) do
      post argument_votes_path(argument),
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

  test 'user should not post create for motion of closed question' do
    sign_in user
    closed_question_motion

    assert_differences([['Vote.count', 0], ['Edge.count', 0]]) do
      post motion_votes_path(closed_question_motion),
           params: {
             for: :pro,
             format: :json
           }
    end

    assert_not_authorized
  end

  test 'user should not post create for argument of closed question' do
    sign_in user
    closed_question_argument

    assert_differences([['Vote.count', 0], ['Edge.count', 0]]) do
      post motion_votes_path(closed_question_argument),
           params: {
             for: :pro,
             format: :json
           }
    end

    assert_response 404
  end

  test 'user should post create json_api' do
    sign_in user

    assert_differences([['Vote.count', 1], ['Edge.count', 1]]) do
      post votes_path,
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :pro,
                 parent: url_for(motion)
               }
             }
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.pro?
  end

  test 'user should not create new vote for motion when existing one is present' do
    create(:vote,
           parent: motion.edge,
           voter: user.profile,
           options: {
             publisher: user,
             owner: user.profile
           },
           for: 'neutral')
    sign_in user

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

  test 'user should not create new vote for argument when existing one is present' do
    create(:vote,
           parent: argument.edge,
           voter: user.profile,
           options: {
             publisher: user,
             owner: user.profile
           },
           for: 'pro')
    sign_in user

    assert_no_difference('Vote.count') do
      post argument_votes_path(argument),
           params: {
             vote: {
               for: 'pro'
             },
             format: :json
           }
    end

    assert_response 304
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
  end

  test 'user should not create new vote when existing one is present json_api' do
    create(:vote,
           parent: motion.edge,
           voter: user.profile,
           options: {
             publisher: user,
             owner: user.profile
           },
           for: 'neutral')
    sign_in user

    assert_no_difference('Vote.count') do
      post votes_path,
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :neutral,
                 parent: url_for(motion)
               }
             }
           }
    end

    assert_response 304
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.neutral?
  end

  test 'user should not create new vote when existing one is present with html' do
    create(:vote,
           parent: motion.edge,
           voter: user.profile,
           options: {
             publisher: user,
             owner: user.profile
           },
           for: 'neutral')
    sign_in user

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

  test 'user should update vote when existing one is present' do
    create(:vote,
           parent: motion.edge,
           voter: user.profile,
           options: {
             publisher: user,
             owner: user.profile
           },
           for: 'neutral')
    sign_in user

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

  test 'user should update vote when existing one is present json_api' do
    create(:vote,
           parent: motion.edge,
           voter: user.profile,
           options: {
             publisher: user,
             owner: user.profile
           },
           for: 'neutral')
    sign_in user

    assert_no_difference('Vote.count') do
      post votes_path,
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :pro,
                 parent: url_for(motion)
               }
             }
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.pro?
  end

  test 'user should delete destroy own vote for motion' do
    user_vote = create(:vote,
                       parent: motion.edge,
                       options: {
                         creator: user.profile
                       },
                       for: 'neutral')
    sign_in user

    assert_differences([['Vote.count', -1], ['Edge.count', -1]]) do
      delete vote_path(user_vote), params: {format: :json}
    end

    assert_response 204
    assert_analytics_collected('votes', 'destroy', 'neutral')
  end

  test 'user should delete destroy own vote for argument' do
    user_vote = create(:vote,
                       parent: argument.edge,
                       options: {
                         creator: user.profile
                       },
                       for: 'neutral')
    sign_in user

    assert_differences([['Vote.count', -1], ['Edge.count', -1]]) do
      delete vote_path(user_vote), params: {format: :json}
    end

    assert_response 204
    assert_analytics_collected('votes', 'destroy', 'neutral')
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(cairo) }

  test 'member shoud get new' do
    sign_in member

    get new_motion_vote_path(cairo_motion)

    assert_response 200
    assert assigns(:model)
  end

  test 'member should post create' do
    sign_in member

    assert_differences([['Vote.count', 1], ['Edge.count', 1]]) do
      post motion_votes_path(cairo_motion),
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

  test 'member should post create json_api' do
    sign_in member

    assert_differences([['Vote.count', 1], ['Edge.count', 1]]) do
      post votes_path,
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :pro,
                 parent: url_for(cairo_motion)
               }
             }
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.pro?
  end

  test 'member should delete destroy own vote' do
    member_vote = create(:vote,
                         parent: cairo_motion.edge,
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

  ####################################
  # As Non-Member
  ####################################
  test 'non-member shoud not get new' do
    sign_in user

    get new_motion_vote_path(cairo_motion)

    assert_response 302
    assert_not_authorized
  end

  test 'non-member should not post create' do
    sign_in user

    assert_differences([['Vote.count', 0], ['Edge.count', 0]]) do
      post motion_votes_path(cairo_motion),
           params: {
             for: :pro,
             format: :json
           }
    end

    assert_response 403
    assert_not_authorized
  end

  test 'non-member should not post create json_api' do
    sign_in user

    assert_differences([['Vote.count', 0], ['Edge.count', 0]]) do
      post votes_path,
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :pro,
                 parent: url_for(cairo_motion)
               }
             }
           }
    end

    assert_response 403
    assert_not_authorized
  end
end
