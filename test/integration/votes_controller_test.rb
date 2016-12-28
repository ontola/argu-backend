# frozen_string_literal: true
require 'test_helper'

class VotesControllerTest < ActionDispatch::IntegrationTest
  define_public_source
  define_freetown
  define_cairo
  let(:closed_question) { create(:question, edge_attributes: {expires_at: 1.day.ago}, parent: freetown.edge) }
  let(:closed_question_motion) { create(:motion, parent: closed_question.edge) }
  let(:closed_question_argument) { create(:argument, parent: closed_question_motion.edge) }
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:argument) { create(:argument, parent: motion.edge) }
  let!(:vote) { create(:vote, parent: motion.default_vote_event.edge) }
  let(:cairo_motion) { create(:motion, parent: cairo.edge) }
  let!(:cairo_vote) { create(:vote, parent: cairo_motion.default_vote_event.edge) }
  let(:linked_record) { create(:linked_record, source: public_source, iri: 'https://iri.test/resource/1') }
  let(:vote_event) do
    create(:vote_event, parent: motion.edge, group: create(:group, parent: freetown.page.edge), ends_at: 1.day.from_now)
  end
  let(:closed_vote_event) do
    create(:vote_event,
           parent: motion.edge,
           group: create(:group, parent: freetown.page.edge),
           ends_at: DateTime.current)
  end

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

    assert_differences([['Vote.count', 1],
                        ['Edge.count', 1],
                        ['motion.default_vote_event.reload.children_count(:votes_pro)', 1]]) do
      post motion_votes_path(motion),
           params: {
             format: :json,
             vote: {
               for: :pro
             }
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

    assert_differences([['Vote.count', 1],
                        ['Edge.count', 1],
                        ['argument.reload.children_count(:votes_pro)', 1]]) do
      post argument_votes_path(argument),
           params: {
             format: :json,
             vote: {
               for: :pro
             }
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

    assert_differences([['Vote.count', 0],
                        ['Edge.count', 0],
                        ['closed_question_motion.default_vote_event.reload.children_count(:votes_pro)', 0]]) do
      post motion_votes_path(closed_question_motion),
           params: {
             format: :json,
             vote: {
               for: :pro
             }
           }
    end

    assert_not_authorized
  end

  test 'user should not post create for argument of closed question' do
    sign_in user
    closed_question_argument

    assert_differences([['Vote.count', 0],
                        ['Edge.count', 0],
                        ['closed_question_argument.reload.children_count(:votes_pro)', 0]]) do
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

    assert_differences([['Vote.count', 1],
                        ['Edge.count', 1],
                        ['motion.default_vote_event.reload.children_count(:votes_pro)', 1]]) do
      post motion_votes_path(motion),
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
               }
             }
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.pro?
  end

  test 'user should post create json_api on vote_event' do
    sign_in user
    create(:group_membership, parent: vote_event.group.edge, member: user.profile)

    assert_differences([['Vote.count', 1],
                        ['Edge.count', 1],
                        ['motion.default_vote_event.reload.children_count(:votes_pro)', 0],
                        ['vote_event.reload.children_count(:votes_pro)', 1]]) do
      post vote_event_votes_path(vote_event),
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
               }
             }
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.pro?
  end

  test 'user should not post create json_api on vote_event without group_membership' do
    sign_in user
    vote_event

    assert_differences([['Vote.count', 0],
                        ['Edge.count', 0],
                        ['motion.default_vote_event.reload.children_count(:votes_pro)', 0],
                        ['vote_event.reload.children_count(:votes_pro)', 0]]) do
      post vote_event_votes_path(vote_event),
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
               }
             }
           }
    end
    assert_not_authorized
  end

  test 'user should not post create json_api on closed vote_event' do
    sign_in user
    create(:group_membership, parent: closed_vote_event.group.edge, member: user.profile)

    assert_differences([['Vote.count', 0],
                        ['Edge.count', 0],
                        ['motion.default_vote_event.reload.children_count(:votes_pro)', 0],
                        ['closed_vote_event.reload.children_count(:votes_pro)', 0]]) do
      post vote_event_votes_path(closed_vote_event),
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
               }
             }
           }
    end
    assert_not_authorized
  end

  test 'user should post create pro json_api for linked record' do
    linked_record_mock(1)
    linked_record_mock(2)
    linked_record
    sign_in user

    assert_differences([['Vote.count', 1], ['Edge.count', 1]]) do
      post linked_record_votes_path(linked_record),
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
               }
             }
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.pro?
  end

  test 'user should post create con json_api for linked record' do
    linked_record_mock(1)
    linked_record_mock(2)
    linked_record
    sign_in user

    assert_differences([['Vote.count', 1], ['Edge.count', 1]]) do
      post linked_record_votes_path(linked_record),
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :con
               }
             }
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.con?
  end

  test 'user should not create new vote for motion when existing one is present' do
    create(:vote,
           parent: motion.default_vote_event.edge,
           voter: user.profile,
           options: {
             publisher: user,
             owner: user.profile
           },
           for: 'neutral')
    sign_in user

    assert_differences([['Vote.count', 0],
                        ['motion.default_vote_event.reload.total_vote_count', 0],
                        ['motion.default_vote_event.children_count(:votes_neutral)', 0]]) do
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

    assert_differences([['Vote.count', 0],
                        ['argument.children_count(:votes_pro)', 0]]) do
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
           parent: motion.default_vote_event.edge,
           voter: user.profile,
           options: {
             publisher: user,
             owner: user.profile
           },
           for: 'neutral')
    sign_in user

    assert_differences([['Vote.count', 0],
                        ['motion.default_vote_event.reload.total_vote_count', 0],
                        ['motion.default_vote_event.children_count(:votes_neutral)', 0]]) do
      post motion_votes_path(motion),
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :neutral
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
           parent: motion.default_vote_event.edge,
           voter: user.profile,
           options: {
             publisher: user,
             owner: user.profile
           },
           for: 'neutral')
    sign_in user

    assert_differences([['Vote.count', 0],
                        ['motion.default_vote_event.reload.total_vote_count', 0],
                        ['motion.default_vote_event.children_count(:votes_neutral)', 0]]) do
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
           parent: motion.default_vote_event.edge,
           voter: user.profile,
           options: {
             publisher: user,
             owner: user.profile
           },
           for: 'neutral')
    sign_in user

    assert_differences([['Vote.count', 0],
                        ['motion.default_vote_event.reload.total_vote_count', 0],
                        ['motion.default_vote_event.children_count(:votes_neutral)', -1],
                        ['motion.default_vote_event.children_count(:votes_pro)', 1]]) do
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
           parent: motion.default_vote_event.edge,
           voter: user.profile,
           options: {
             publisher: user,
             owner: user.profile
           },
           for: 'neutral')
    sign_in user

    assert_differences([['Vote.count', 0],
                        ['motion.default_vote_event.reload.total_vote_count', 0],
                        ['motion.default_vote_event.children_count(:votes_neutral)', -1],
                        ['motion.default_vote_event.children_count(:votes_pro)', 1]]) do
      post motion_votes_path(motion),
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
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
                       parent: motion.default_vote_event.edge,
                       options: {
                         creator: user.profile
                       },
                       for: 'neutral')
    sign_in user

    assert_differences([['Vote.count', -1],
                        ['Edge.count', -1],
                        ['motion.default_vote_event.reload.children_count(:votes_neutral)', -1]]) do
      delete vote_path(user_vote), params: {format: :json}
    end

    assert_response 204
    assert_analytics_collected('votes', 'destroy', 'neutral')
  end

  test 'user should not delete destroy own vote for motion twice' do
    user_vote = create(:vote,
                       parent: motion.default_vote_event.edge,
                       options: {
                         creator: user.profile
                       },
                       for: 'neutral')
    sign_in user

    assert_differences([['Vote.count', -1],
                        ['Edge.count', -1],
                        ['motion.default_vote_event.reload.children_count(:votes_neutral)', -1]]) do
      delete vote_path(user_vote), params: {format: :json}
    end

    assert_differences([['Vote.count', 0],
                        ['Edge.count', 0],
                        ['motion.default_vote_event.reload.children_count(:votes_neutral)', 0]]) do
      delete vote_path(user_vote), params: {format: :json}
    end

    assert_response 404
  end

  test 'user should delete destroy own vote for argument' do
    user_vote = create(:vote,
                       parent: argument.edge,
                       options: {
                         creator: user.profile
                       },
                       for: 'neutral')
    sign_in user

    assert_differences([['Vote.count', -1],
                        ['Edge.count', -1],
                        ['argument.reload.children_count(:votes_neutral)', -1]]) do
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

    assert_differences([['Vote.count', 1],
                        ['Edge.count', 1],
                        ['cairo_motion.default_vote_event.reload.children_count(:votes_pro)', 1]]) do
      post motion_votes_path(cairo_motion),
           params: {
             format: :json,
             vote: {
               for: :pro
             }
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert_analytics_collected('votes', 'create', 'pro')
  end

  test 'member should post create json_api' do
    sign_in member

    assert_differences([['Vote.count', 1],
                        ['Edge.count', 1],
                        ['cairo_motion.default_vote_event.reload.children_count(:votes_pro)', 1]]) do
      post motion_votes_path(cairo_motion),
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
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
                         parent: cairo_motion.default_vote_event.edge,
                         options: {
                           creator: member.profile
                         },
                         for: 'neutral')
    sign_in member

    assert_differences([['Vote.count', -1],
                        ['Edge.count', -1],
                        ['cairo_motion.default_vote_event.reload.children_count(:votes_neutral)', -1]]) do
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

    assert_response 403
    assert_not_authorized
  end

  test 'non-member should not post create' do
    sign_in user

    assert_differences([['Vote.count', 0], ['Edge.count', 0]]) do
      post motion_votes_path(cairo_motion),
           params: {
             format: :json,
             vote: {
               for: :pro
             }
           }
    end

    assert_response 403
    assert_not_authorized
  end

  test 'non-member should not post create json_api' do
    sign_in user

    assert_differences([['Vote.count', 0], ['Edge.count', 0]]) do
      post motion_votes_path(cairo_motion),
           params: {
             format: :json_api,
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
               }
             }
           }
    end

    assert_response 403
    assert_not_authorized
  end
end
