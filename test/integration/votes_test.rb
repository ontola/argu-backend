# frozen_string_literal: true
require 'test_helper'

class VotesTest < ActionDispatch::IntegrationTest
  define_public_source
  define_freetown
  define_cairo
  let(:guest_user) { GuestUser.new(session: session) }
  let(:other_guest_user) { GuestUser.new(id: 'other_id') }
  let(:closed_question) { create(:question, edge_attributes: {expires_at: 1.day.ago}, parent: freetown.edge) }
  let(:closed_question_motion) { create(:motion, parent: closed_question.edge) }
  let(:closed_question_argument) { create(:argument, parent: closed_question_motion.edge) }
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:motion2) { create(:motion, parent: freetown.edge) }
  let(:argument) { create(:argument, parent: motion.edge) }
  let(:argument2) { create(:argument, parent: motion.edge) }
  let(:argument3) { create(:argument, parent: motion.edge) }
  let!(:vote) { create(:vote, parent: motion.default_vote_event.edge, creator: creator.profile, publisher: creator) }
  let(:guest_vote) do
    create(:vote, parent: motion.default_vote_event.edge, creator: guest_user.profile, publisher: guest_user)
  end
  let(:guest_vote2) do
    create(:vote, parent: motion2.default_vote_event.edge, creator: guest_user.profile, publisher: guest_user)
  end
  let(:other_guest_vote) do
    create(:vote,
           parent: motion.default_vote_event.edge,
           creator: other_guest_user.profile,
           publisher: other_guest_user)
  end
  let(:other_guest_vote2) do
    create(:vote,
           parent: motion2.default_vote_event.edge,
           creator: other_guest_user.profile,
           publisher: other_guest_user)
  end
  let(:unconfirmed_vote) do
    create(:vote, parent: motion.default_vote_event.edge, creator: unconfirmed.profile, publisher: unconfirmed)
  end
  let(:unconfirmed_vote2) do
    create(:vote, parent: motion2.default_vote_event.edge, creator: unconfirmed.profile, publisher: unconfirmed)
  end
  let(:hidden_vote) do
    create(:vote,
           parent: motion.default_vote_event.edge,
           creator: profile_hidden_votes,
           publisher: profile_hidden_votes.profileable)
  end
  let!(:argument_vote) { create(:vote, parent: argument.edge, creator: creator.profile, publisher: creator) }
  let(:argument_guest_vote) do
    create(:vote, parent: argument.edge, creator: guest_user.profile, publisher: guest_user)
  end
  let(:argument_guest_vote3) do
    create(:vote, parent: argument3.edge, creator: guest_user.profile, publisher: guest_user)
  end
  let!(:argument_unconfirmed_vote) do
    create(:vote, parent: argument.edge, creator: unconfirmed.profile, publisher: unconfirmed)
  end
  let!(:argument_unconfirmed_vote3) do
    create(:vote, parent: argument3.edge, creator: unconfirmed.profile, publisher: unconfirmed)
  end
  let(:cairo_motion) { create(:motion, parent: cairo.edge) }
  let!(:cairo_vote) { create(:vote, parent: cairo_motion.default_vote_event.edge) }
  let(:linked_record) { create(:linked_record, source: public_source, iri: 'https://iri.test/resource/1') }
  let(:vote_event) do
    create(:vote_event,
           parent: motion.edge,
           group: create(:group, parent: freetown.page.edge),
           edge_attributes: {expires_at: 1.day.from_now})
  end
  let(:closed_vote_event) do
    create(:vote_event,
           parent: motion.edge,
           group: create(:group, parent: freetown.page.edge),
           edge_attributes: {expires_at: DateTime.current})
  end
  let(:creator) { create(:user) }
  let(:profile_hidden_votes) { create(:user, profile: build(:profile, are_votes_public: false)).profile }

  ####################################
  # as Guest
  ####################################
  test 'guest should get show other json_api' do
    get vote_path(vote), params: {format: :json_api}

    assert_response 200
  end

  test 'guest should not get show json_api of user with hidden votes' do
    get vote_path(hidden_vote), params: {format: :json_api}

    assert_not_authorized
  end

  test 'guest should get show vote' do
    get root_path
    guest_vote
    get motion_show_vote_path(motion.id, format: :json_api)
    assert_response 200

    expect_relationship('parent')
    creator = expect_relationship('creator')
    assert_equal creator.dig('data', 'id'), "https://127.0.0.1:42000/sessions/#{session.id}"
    assert_equal creator.dig('links', 'related', 'href'), "https://127.0.0.1:42000/sessions/#{session.id}"
  end

  test 'guest should not get show non-existent vote' do
    get root_path
    guest_vote2
    other_guest_vote
    get motion_show_vote_path(motion.id, format: :json_api)
    assert_response 404
  end

  test 'guest should not get new' do
    get new_motion_vote_path(motion)

    assert_redirected_to new_user_session_path(r: new_motion_vote_path(confirm: true))
    assert_not assigns(:model)
  end

  test 'guest should post create vote for motion' do
    get root_path
    post motion_votes_path(motion.id, format: :json_api, vote: {for: :con})
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#no'
    get motion_show_vote_path(motion.id, format: :json_api)
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#no'
  end

  test 'guest should post create vote for vote_event' do
    get root_path
    assert_difference('Argu::Redis.keys("temporary.*").count', 1) do
      post vote_event_votes_path(motion.default_vote_event.id, format: :json_api, vote: {for: :con})
    end
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#no'
    get motion_show_vote_path(motion.id, format: :json_api)
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#no'
  end

  test 'guest should post create for motion with upvoted arguments json' do
    get root_path
    argument_guest_vote
    argument_guest_vote3
    argument2

    assert_differences([['Vote.count', 0],
                        ['Edge.count', 0],
                        ['motion.default_vote_event.reload.children_count(:votes_pro)', 0]]) do
      Sidekiq::Testing.inline! do
        post motion_votes_path(motion),
             params: {
               format: :json,
               vote: {
                 for: :pro,
                 argument_ids: [argument.id, argument2.id]
               }
             }
      end
    end

    assert_redis_resource_count(0, owner_type: 'Vote', publisher: guest_user, parent: argument3.edge)
    assert_redis_resource_count(1, owner_type: 'Vote', publisher: guest_user, parent: argument.edge)
    assert_redis_resource_count(1, owner_type: 'Vote', publisher: guest_user, parent: argument2.edge)
    assert_response 200
  end

  test 'guest should post not create vote for closed motion' do
    get root_path
    post motion_votes_path(closed_question_motion.id, format: :json_api, vote: {for: :con})
    assert_response 403
    get motion_show_vote_path(closed_question_motion.id, format: :json_api)
    assert_response 404
  end

  test 'guest should post update vote' do
    get root_path
    guest_vote
    get motion_show_vote_path(motion.id, format: :json_api)
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#yes'
    assert_no_difference('Argu::Redis.keys("temporary.*").count') do
      post motion_votes_path(motion.id, format: :json_api, vote: {for: :con})
    end
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#no'
    get motion_show_vote_path(motion.id, format: :json_api)
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#no'
  end

  ####################################
  # As Unconfirmed user
  ####################################
  let(:unconfirmed) { create(:user, :unconfirmed) }

  test 'unconfirmed should get show other json_api' do
    sign_in unconfirmed
    get vote_path(vote), params: {format: :json_api}

    assert_response 200
  end

  test 'unconfirmed should not get show json_api of user with hidden votes' do
    sign_in unconfirmed
    get vote_path(hidden_vote), params: {format: :json_api}

    assert_not_authorized
  end

  test 'unconfirmed should get show vote' do
    sign_in unconfirmed
    get root_path
    unconfirmed_vote
    get motion_show_vote_path(motion.id, format: :json_api)
    assert_response 200

    expect_relationship('parent')
    creator = expect_relationship('creator')
    assert_equal creator.dig('data', 'id'), "https://127.0.0.1:42000/u/#{unconfirmed.id}"
    assert_equal creator.dig('links', 'related', 'href'), "https://127.0.0.1:42000/u/#{unconfirmed.id}"
  end

  test 'unconfirmed should not get show non-existent vote' do
    sign_in unconfirmed
    get root_path
    other_guest_vote
    unconfirmed_vote2
    get motion_show_vote_path(motion.id, format: :json_api)
    assert_response 404
  end

  test 'unconfirmed should post create vote for motion' do
    sign_in unconfirmed
    get root_path
    post motion_votes_path(motion.id, format: :json_api, vote: {for: :con})
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#no'
    get motion_show_vote_path(motion.id, format: :json_api)
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#no'
  end

  test 'unconfirmed should post create vote for vote_event' do
    sign_in unconfirmed
    get root_path
    assert_difference('Argu::Redis.keys("temporary.*").count', 1) do
      post vote_event_votes_path(motion.default_vote_event.id, format: :json_api, vote: {for: :con})
    end
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#no'
    get motion_show_vote_path(motion.id, format: :json_api)
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#no'
  end

  test 'unconfirmed should post create for motion with upvoted arguments json' do
    sign_in unconfirmed
    get root_path
    argument_unconfirmed_vote
    argument_unconfirmed_vote3
    argument2
    assert_redis_resource_count(1, owner_type: 'Vote', publisher: unconfirmed, parent: argument3.edge)

    assert_differences([['Vote.count', 0],
                        ['Edge.count', 0],
                        ['motion.default_vote_event.reload.children_count(:votes_pro)', 0]]) do
      post motion_votes_path(motion),
           params: {
             format: :json,
             vote: {
               for: :pro,
               argument_ids: [argument.id, argument2.id]
             }
           }
    end

    assert_redis_resource_count(0, owner_type: 'Vote', publisher: unconfirmed, parent: argument3.edge)
    assert_redis_resource_count(1, owner_type: 'Vote', publisher: unconfirmed, parent: argument.edge)
    assert_redis_resource_count(1, owner_type: 'Vote', publisher: unconfirmed, parent: argument2.edge)
    assert_response 200
  end

  test 'unconfirmed should post not create vote for closed motion' do
    sign_in unconfirmed
    get root_path
    post motion_votes_path(closed_question_motion.id, format: :json_api, vote: {for: :con})
    assert_response 403
    get motion_show_vote_path(closed_question_motion.id, format: :json_api)
    assert_response 404
  end

  test 'unconfirmed should post update vote' do
    sign_in unconfirmed
    get root_path
    unconfirmed_vote
    get motion_show_vote_path(motion.id, format: :json_api)
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#yes'
    assert_differences([['Argu::Redis.keys("temporary.*").count', 0], ['Vote.count', 0]]) do
      post motion_votes_path(motion.id, format: :json_api, vote: {for: :con})
    end
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#no'
    get motion_show_vote_path(motion.id, format: :json_api)
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#no'
  end

  test 'unconfirmed should post update vote that also exists in postgres' do
    sign_in creator
    get root_path
    key = RedisResource::Key.new(
      path: vote.parent_edge.path,
      owner_type: 'Vote',
      user: vote.publisher,
      edge_id: vote.edge.id
    ).key
    Argu::Redis.set(key, vote.attributes.merge(persisted: true).to_json)
    creator.primary_email_record.update(confirmed_at: nil)

    get motion_show_vote_path(motion.id, format: :json_api)
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#yes'
    assert_differences([['Vote.pro.count', -1], ['Vote.con.count', 1], ['Argu::Redis.keys("temporary.*").count', 0]]) do
      assert vote.pro?
      assert RedisResource::Relation.where(publisher: creator).first.resource.pro?
      post motion_votes_path(motion.id, format: :json_api, vote: {for: :con})
      assert vote.reload.con?
      assert RedisResource::Relation.where(publisher: creator).first.resource.con?
    end
    assert_response 200
    assert_equal parsed_body['data']['attributes']['option'], 'https://argu.co/ns/core#no'
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get new' do
    sign_in user

    get new_motion_vote_path(motion)

    assert_response 200
    assert assigns(:model)
  end

  test 'user should get show json_api' do
    sign_in user

    get vote_path(vote), params: {format: :json_api}

    assert_response 200
  end

  test 'user should not get show json_api of user with hidden votes' do
    sign_in user

    get vote_path(hidden_vote), params: {format: :json_api}

    assert_not_authorized
  end

  test 'user without vote should not get show own vote json_api' do
    sign_in user

    get motion_show_vote_path(motion), params: {format: :json_api}

    assert_response 404
  end

  test 'user should post create for motion json' do
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

  test 'user should post create for motion with upvoted arguments json' do
    sign_in user
    create(:vote, parent: argument.edge, creator: user.profile, publisher: user)
    vote_to_remove = create(:vote, parent: argument3.edge, creator: user.profile, publisher: user)
    argument2

    assert_differences([['Vote.count', 1],
                        ['Edge.count', 1],
                        ['motion.default_vote_event.reload.children_count(:votes_pro)', 1]]) do
      post motion_votes_path(motion),
           params: {
             format: :json,
             vote: {
               for: :pro,
               argument_ids: [argument.id, argument2.id]
             }
           }
    end

    assert Vote.find_by(id: vote_to_remove.id).nil?
    assert Vote.find_by(voteable_id: argument.id, voteable_type: 'Argument').present?
    assert Vote.find_by(voteable_id: argument2.id, voteable_type: 'Argument').present?
    assert_response 200
    assert_analytics_collected('votes', 'create', 'pro')
  end

  test 'user should post create for argument json' do
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
      post argument_votes_path(closed_question_argument),
           params: {
             for: :pro,
             format: :json
           }
    end

    assert_not_authorized
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
    assert assigns(:create_service).resource.pro?
    assert_nil assigns(:create_service).resource.explanation
    assert_nil assigns(:create_service).resource.explained_at
  end

  test 'user should post create json_api with explanation' do
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
                 side: :pro,
                 explanation: 'Explanation'
               }
             }
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.pro?
    assert_equal 'Explanation', assigns(:create_service).resource.explanation
    assert_not_nil assigns(:create_service).resource.explained_at
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

  test "user should not delete destroy others' vote" do
    sign_in user

    vote # Trigger
    assert_no_difference('Vote.count') do
      delete vote_path(vote.id), params: {format: :json}
    end

    assert_response 403
  end

  ####################################
  # As Creator
  ####################################
  test 'creator should get show json_api' do
    sign_in creator

    get vote_path(vote), params: {format: :json_api}

    assert_response 200
  end

  test 'creator should get show own vote json_api' do
    sign_in creator

    get motion_show_vote_path(motion), params: {format: :json_api}

    assert_response 200
  end

  test 'creator should not create unchanged vote for motion json' do
    sign_in creator

    assert_differences([['Vote.count', 0],
                        ['motion.default_vote_event.reload.total_vote_count', 0],
                        ['motion.default_vote_event.children_count(:votes_pro)', 0]]) do
      post motion_votes_path(motion),
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

  test 'creator should not create unchanged vote for argument json' do
    sign_in creator

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

  test 'creator should not create unchanged vote json_api' do
    sign_in creator

    assert_differences([['Vote.count', 0],
                        ['motion.default_vote_event.reload.total_vote_count', 0],
                        ['motion.default_vote_event.children_count(:votes_pro)', 0]]) do
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

    assert_response 304
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.pro?
  end

  test 'creator should not create new vote html' do
    sign_in creator

    assert_differences([['Vote.count', 0],
                        ['motion.default_vote_event.reload.total_vote_count', 0],
                        ['motion.default_vote_event.children_count(:votes_pro)', 0]]) do
      post motion_votes_path(motion),
           params: {
             vote: {
               for: 'pro'
             }
           }
    end

    assert_redirected_to motion_path(motion)
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
  end

  test 'creator should post update side json' do
    sign_in creator

    assert_differences([['Vote.count', 0],
                        ['Activity.count', 0],
                        ['motion.default_vote_event.reload.total_vote_count', 0],
                        ['motion.default_vote_event.children_count(:votes_pro)', -1],
                        ['motion.default_vote_event.children_count(:votes_con)', 1]]) do
      post motion_votes_path(motion),
           params: {
             vote: {
               for: 'con'
             },
             format: :json
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
    assert_analytics_collected('votes', 'update', 'con')
  end

  test 'creator should post update explanation json' do
    sign_in creator
    assert_differences([['Vote.count', 0],
                        ['motion.default_vote_event.reload.total_vote_count', 0],
                        ['motion.default_vote_event.children_count(:votes_pro)', 0],
                        ['motion.default_vote_event.children_count(:votes_con)', 0]]) do
      post motion_votes_path(motion),
           params: {
             vote: {
               for: 'pro',
               explanation: 'This is my opinion'
             },
             format: :json
           }
    end

    assert_response 200
    assert assigns(:model)
    assert assigns(:create_service).resource.valid?
  end

  test 'creator should post update json_api' do
    sign_in creator

    assert_differences([['Vote.count', 0],
                        ['motion.default_vote_event.reload.total_vote_count', 0],
                        ['motion.default_vote_event.children_count(:votes_pro)', -1],
                        ['motion.default_vote_event.children_count(:votes_con)', 1]]) do
      post motion_votes_path(motion),
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

  test 'creator should delete destroy vote for motion json' do
    sign_in creator

    assert_differences([['Vote.count', -1],
                        ['Edge.count', -1],
                        ['motion.default_vote_event.reload.children_count(:votes_pro)', -1]]) do
      delete vote_path(vote), params: {format: :json}
    end

    assert_response 204
    assert_analytics_collected('votes', 'destroy', 'pro')
  end

  test 'creator should not put update json_api side' do
    sign_in creator

    assert_differences([['Vote.count', 0],
                        ['motion.default_vote_event.reload.total_vote_count', 0],
                        ['motion.default_vote_event.children_count(:votes_pro)', 0],
                        ['motion.default_vote_event.children_count(:votes_con)', 0]]) do
      put vote_path(vote),
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

    assert_response 204
    assert assigns(:update_service).resource.valid?
    assert assigns(:update_service).resource.pro?
  end

  test 'creator should put update json_api explanation' do
    sign_in creator

    put vote_path(vote),
        params: {
          format: :json_api,
          data: {
            type: 'votes',
            attributes: {
              explanation: 'Updated explanation'
            }
          }
        }

    assert_response 204
    assert_equal 'Updated explanation', vote.reload.explanation
    assert_not_nil vote.reload.explained_at
  end

  test 'creator should not delete destroy vote for motion twice' do
    sign_in creator

    assert_differences([['Vote.count', -1],
                        ['Edge.count', -1],
                        ['motion.default_vote_event.reload.children_count(:votes_pro)', -1]]) do
      delete vote_path(vote), params: {format: :json}
    end

    assert_differences([['Vote.count', 0],
                        ['Edge.count', 0],
                        ['motion.default_vote_event.reload.children_count(:votes_pro)', 0]]) do
      delete vote_path(vote), params: {format: :json}
    end

    assert_response 404
  end

  test 'creator should delete destroy vote for argument' do
    sign_in creator

    assert_differences([['Vote.count', -1],
                        ['Edge.count', -1],
                        ['argument.reload.children_count(:votes_pro)', -1]]) do
      delete vote_path(argument_vote), params: {format: :json}
    end

    assert_response 204
    assert_analytics_collected('votes', 'destroy', 'pro')
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(cairo) }

  test 'member should get new' do
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
  test 'non-member should not get new' do
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

  private

  def assert_redis_resource_count(count, opts)
    assert_equal count, RedisResource::Relation.where(opts).count
  end
end
