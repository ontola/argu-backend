# frozen_string_literal: true

require 'test_helper'

class VotesTest < ActionDispatch::IntegrationTest
  define_freetown
  define_cairo
  let(:guest_user) { create_guest_user }
  let(:other_guest_user) { create_guest_user(id: 'other_id') }
  let(:closed_question) { create(:question, expires_at: 1.day.ago, parent: freetown) }
  let(:closed_question_motion) { create(:motion, parent: closed_question) }
  let(:closed_question_argument) { create(:argument, parent: closed_question_motion) }
  let(:motion) { create(:motion, parent: freetown) }
  let(:motion2) { create(:motion, parent: freetown) }
  let(:argument) { create(:argument, parent: motion) }
  let(:argument2) { create(:argument, parent: motion) }
  let(:argument3) { create(:argument, parent: motion) }
  let!(:vote) { create(:vote, parent: vote_event, creator: creator.profile, publisher: creator) }
  let(:guest_vote) do
    create(:vote, parent: vote_event, creator: guest_user.profile, publisher: guest_user)
  end
  let(:guest_vote2) do
    create(:vote, parent: motion2.default_vote_event, creator: guest_user.profile, publisher: guest_user)
  end
  let(:other_guest_vote) do
    create(:vote,
           parent: vote_event,
           creator: other_guest_user.profile,
           publisher: other_guest_user)
  end
  let(:other_guest_vote2) do
    create(:vote,
           parent: motion2.default_vote_event,
           creator: other_guest_user.profile,
           publisher: other_guest_user)
  end
  let(:unconfirmed_vote) do
    create(:vote, parent: vote_event, creator: unconfirmed.profile, publisher: unconfirmed)
  end
  let(:unconfirmed_vote2) do
    create(:vote, parent: motion2.default_vote_event, creator: unconfirmed.profile, publisher: unconfirmed)
  end
  let(:hidden_vote) do
    create(:vote,
           parent: vote_event,
           creator: profile_hidden_votes,
           publisher: profile_hidden_votes.profileable)
  end
  let!(:argument_vote) { create(:vote, parent: argument, creator: creator.profile, publisher: creator) }
  let(:argument_guest_vote) do
    create(:vote, parent: argument, creator: guest_user.profile, publisher: guest_user)
  end
  let(:argument_guest_vote3) do
    create(:vote, parent: argument3, creator: guest_user.profile, publisher: guest_user)
  end
  let!(:argument_unconfirmed_vote) do
    create(:vote, parent: argument, creator: unconfirmed.profile, publisher: unconfirmed)
  end
  let!(:argument_unconfirmed_vote3) do
    create(:vote, parent: argument3, creator: unconfirmed.profile, publisher: unconfirmed)
  end
  let(:cairo_motion) { create(:motion, parent: cairo) }
  let!(:cairo_vote) { create(:vote, parent: cairo_motion.default_vote_event) }
  let(:linked_record) { LinkedRecord.create_for_forum(argu.url, freetown.url, SecureRandom.uuid) }
  let(:non_persisted_linked_record) { LinkedRecord.new_for_forum(argu.url, freetown.url, SecureRandom.uuid) }
  let(:vote_event) do
    create(:vote_event,
           parent: motion,
           expires_at: 1.day.from_now)
  end
  let(:closed_vote_event) do
    create(:vote_event,
           parent: motion,
           expires_at: Time.current)
  end
  let(:creator) { create(:user) }
  let(:profile_hidden_votes) { create(:user, profile: build(:profile, are_votes_public: false)).profile }
  let(:context) { UserContext.new(doorkeeper_scopes: 'test afe') }

  ####################################
  # as Guest
  ####################################
  test 'guest should get show vote by parent' do
    get root_path
    guest_vote
    get expand_uri_template(:vote_iri, parent_iri: split_iri_segments(vote_event.iri.path)),
        headers: argu_headers(accept: :json_api)
    assert_response 200

    expect_relationship('partOf')
    creator = expect_relationship('creator')
    assert_equal creator.dig('data', 'id'), "#{Rails.application.config.origin}/#{argu.url}/sessions/#{session.id}"
  end

  test 'guest should not get show non-existent vote' do
    get root_path
    guest_vote2
    other_guest_vote
    current_vote = ActsAsTenant.with_tenant(argu) { current_vote_iri(vote_event) }
    get current_vote, headers: argu_headers(accept: :json_api)
    assert_equal parsed_body['data']['attributes']['option'], NS::ARGU[:abstain].to_s
  end

  test 'guest should post create for motion json' do
    get root_path
    assert_difference('Vote.count' => 0,
                      'Edge.count' => 0,
                      'Argu::Redis.keys.count' => 1,
                      'vote_event.reload.children_count(:votes_pro)' => 0) do
      Sidekiq::Testing.inline! do
        post collection_iri(vote_event, :votes),
             params: {
               vote: {for: :pro}
             },
             headers: argu_headers(accept: :json)
      end
    end

    assert_redis_resource_count(1, owner_type: 'Vote', publisher: guest_user, parent: vote_event)
    assert_response 201
  end

  test 'guest should post create for motion with new fe' do
    sign_in guest_user, Doorkeeper::Application.argu_front_end

    expect(vote_event.votes.length).to be 1
    assert_difference('Vote.count' => 0,
                      'Edge.count' => 0,
                      'vote_event.reload.children_count(:votes_con)' => 0) do
      Sidekiq::Testing.inline! do
        post collection_iri(vote_event, :votes, 'filter%5B%5D' => 'option=no', type: :paginated),
             headers: argu_headers(accept: :nq)
      end
    end

    expect_triple(
      resource_iri(vote_event.vote_collection(user_context: context), root: argu),
      NS::AS[:totalItems],
      1,
      NS::ONTOLA[:replace]
    )
    expect_triple(
      resource_iri(vote_event.vote_collection(user_context: context, filter: {option: :yes}), root: argu),
      NS::AS[:totalItems],
      1,
      NS::ONTOLA[:replace]
    )
    expect_triple(
      resource_iri(vote_event.vote_collection(user_context: context, filter: {option: :other}), root: argu),
      NS::AS[:totalItems],
      0,
      NS::ONTOLA[:replace]
    )
    expect_triple(
      resource_iri(vote_event.vote_collection(user_context: context, filter: {option: :no}), root: argu),
      NS::AS[:totalItems],
      0,
      NS::ONTOLA[:replace]
    )

    assert_response 201
  end

  test 'guest should post not create vote for closed motion' do
    get root_path
    post collection_iri(closed_question_motion.default_vote_event, :votes, canonical: true),
         params: {
           vote: {for: :con}
         },
         headers: argu_headers(accept: :json_api)
    assert_response 403
    current_vote = ActsAsTenant.with_tenant(argu) { current_vote_iri(closed_question_motion.default_vote_event) }
    get current_vote, headers: argu_headers(accept: :json_api)
    assert_equal parsed_body['data']['attributes']['option'], NS::ARGU[:abstain].to_s
  end

  test 'guest should post update vote' do
    get root_path
    guest_vote
    get expand_uri_template(:vote_iri, parent_iri: split_iri_segments(vote_event.iri.path)),
        headers: argu_headers(accept: :json_api)
    assert_response 200
    assert_equal primary_resource['attributes']['option'], NS::ARGU[:yes]
    assert_no_difference('Argu::Redis.keys("temporary.*").count') do
      post collection_iri(vote_event, :votes, canonical: true),
           params: {vote: {for: :con}},
           headers: argu_headers(accept: :json_api)
    end
    assert_response 201
    assert_equal primary_resource['attributes']['option'], NS::ARGU[:no]
    get expand_uri_template(:vote_iri, parent_iri: split_iri_segments(vote_event.iri.path)),
        headers: argu_headers(accept: :json_api)
    assert_response 200
    assert_equal primary_resource['attributes']['option'], NS::ARGU[:no]
  end

  test 'guest should delete destroy argument vote' do
    get root_path
    argument_guest_vote
    assert_difference('Argu::Redis.keys("temporary.*").count', -1) do
      delete expand_uri_template(:vote_iri, parent_iri: split_iri_segments(argument.iri.path), for: :pro)
      assert_response 303
    end
  end

  ####################################
  # As Unconfirmed user
  ####################################
  let(:unconfirmed) { create(:unconfirmed_user) }

  test 'unconfirmed should get show vote' do
    sign_in unconfirmed
    get root_path
    unconfirmed_vote
    get expand_uri_template(:vote_iri, parent_iri: split_iri_segments(vote_event.iri.path)),
        headers: argu_headers(accept: :json_api)
    assert_response 200

    expect_relationship('partOf')
    creator = expect_relationship('creator')
    assert_equal creator.dig('data', 'id'), "#{Rails.application.config.origin}/#{argu.url}/u/#{unconfirmed.url}"
  end

  test 'unconfirmed should not get show non-existent vote' do
    sign_in unconfirmed
    get root_path
    other_guest_vote
    unconfirmed_vote2
    current_vote = ActsAsTenant.with_tenant(argu) { current_vote_iri(vote_event) }
    get current_vote, headers: argu_headers(accept: :json_api)
    assert_equal parsed_body['data']['attributes']['option'], NS::ARGU[:abstain].to_s
  end

  test 'unconfirmed should post create for motion with json' do
    sign_in unconfirmed
    get root_path

    assert_difference('Vote.count' => 1,
                      'Edge.count' => 1,
                      'vote_event.reload.children_count(:votes_pro)' => 0) do
      post collection_iri(vote_event, :votes, canonical: true),
           params: {
             vote: {for: :pro}
           },
           headers: argu_headers(accept: :json)
    end

    assert_response 201
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should post create for motion json' do
    sign_in user
    vote_event
    assert_difference('Vote.count' => 1,
                      'Edge.count' => 1,
                      'Argu::Redis.keys.count' => 0,
                      'vote_event.reload.children_count(:votes_pro)' => 1) do
      post collection_iri(vote_event, :votes, canonical: true),
           params: {
             vote: {for: :pro}
           },
           headers: argu_headers(accept: :json)
    end

    assert_response 201
  end

  test 'user should post create for motion with default id' do
    sign_in user
    motion
    default_iri = motion.default_vote_event.iri_path(id: 'default')
    assert default_iri.include?('default')
    iri = ActsAsTenant.with_tenant(argu) { collection_iri(default_iri, :votes, canonical: true) }
    assert_difference('Vote.count' => 1, 'Edge.count' => 1) do
      post iri,
           params: {
             vote: {
               for: :pro
             }
           },
           headers: argu_headers(accept: :json)
    end
    assert_response 201
  end

  test 'user should post create upvote for argument json' do
    sign_in user
    argument

    assert_difference('Vote.count' => 1,
                      'Edge.count' => 1,
                      'argument.reload.children_count(:votes_pro)' => 1) do
      post collection_iri(argument, :votes, canonical: true),
           params: {
             for: :pro
           },
           headers: argu_headers(accept: :json)
    end

    assert_response 201
    assert assigns(:create_service).resource.valid?
  end

  test 'user should post create json_api' do
    sign_in user

    assert_difference('Vote.count' => 1,
                      'Edge.count' => 1,
                      'vote_event.reload.children_count(:votes_pro)' => 1) do
      post collection_iri(vote_event, :votes, canonical: true),
           params: {
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
               }
             }
           },
           headers: argu_headers(accept: :json_api)
    end

    assert_response 201
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.pro?
  end

  test 'user should not post create json_api on closed vote_event' do
    sign_in user
    closed_vote_event

    assert_difference('Vote.count' => 0,
                      'Edge.count' => 0,
                      'vote_event.reload.children_count(:votes_pro)' => 0,
                      'closed_vote_event.reload.children_count(:votes_pro)' => 0) do
      post collection_iri(closed_vote_event, :votes, canonical: true),
           params: {
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
               }
             }
           },
           headers: argu_headers(accept: :json_api)
    end
    assert_response :forbidden
  end

  test 'user should post create pro json_api for linked record' do
    linked_record
    sign_in user

    assert_difference('Vote.count' => 1, 'Edge.count' => 1) do
      vote_event = linked_record.default_vote_event
      post collection_iri(vote_event, :votes, canonical: true),
           params: {
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
               }
             }
           },
           headers: argu_headers(accept: :json_api)
    end

    assert_response 201
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.pro?
  end

  test 'user should post create pro json_api for linked record width default id' do
    linked_record
    sign_in user

    default_iri = linked_record.default_vote_event.iri_path(id: 'default')
    assert default_iri.include?('default')
    iri = ActsAsTenant.with_tenant(argu) { collection_iri(default_iri, :votes, canonical: true) }

    assert_difference('Vote.count' => 1, 'Edge.count' => 1) do
      post iri,
           params: {
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
               }
             }
           },
           headers: argu_headers(accept: :json_api)
    end

    assert_response 201
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.pro?
  end

  test 'user should post create pro json_api for non-persisted linked record' do
    sign_in user

    default_iri = non_persisted_linked_record.default_vote_event.iri_path(id: 'default')
    assert default_iri.include?('default')
    iri = ActsAsTenant.with_tenant(argu) { collection_iri(default_iri, :votes, canonical: true) }

    assert_difference('Vote.count' => 1, 'LinkedRecord.count' => 1, 'VoteEvent.count' => 1, 'Edge.count' => 3) do
      post iri,
           params: {
             data: {
               type: 'votes',
               attributes: {
                 side: :pro
               }
             }
           },
           headers: argu_headers(accept: :json_api)
    end

    assert_response 201
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.pro?
  end

  ####################################
  # As Creator
  ####################################
  test 'creator should not create unchanged vote for motion json' do
    sign_in creator

    assert_difference('Vote.count' => 0,
                      'vote_event.reload.total_vote_count' => 0,
                      'vote_event.children_count(:votes_pro)' => 0) do
      post collection_iri(vote_event, :votes, canonical: true),
           params: {
             vote: {
               for: 'pro'
             }
           },
           headers: argu_headers(accept: :json)
    end

    assert_response 304
    assert assigns(:create_service).resource.valid?
  end

  test 'creator should not create new vote html' do
    sign_in creator

    assert_difference('Vote.count' => 0,
                      'vote_event.reload.total_vote_count' => 0,
                      'vote_event.children_count(:votes_pro)' => 0) do
      post collection_iri(vote_event, :votes, canonical: true),
           params: {
             vote: {
               for: 'pro'
             }
           }
    end

    assert_redirected_to argu_url(motion.iri.path)
    assert assigns(:create_service).resource.valid?
  end

  test 'creator should post update side json' do
    sign_in creator

    assert_difference('Vote.count' => 1,
                      'Vote.untrashed.count' => 0,
                      'Activity.count' => 0,
                      'vote_event.reload.total_vote_count' => 0,
                      'vote_event.children_count(:votes_pro)' => -1,
                      'vote_event.children_count(:votes_con)' => 1) do
      post collection_iri(vote_event, :votes, canonical: true),
           params: {
             vote: {
               for: 'con'
             }
           },
           headers: argu_headers(accept: :json)
    end

    assert_response 201
    assert assigns(:create_service).resource.valid?
  end

  test 'creator should post update json_api' do
    sign_in creator

    assert_difference('Vote.count' => 1,
                      'Vote.untrashed.count' => 0,
                      'vote_event.reload.total_vote_count' => 0,
                      'vote_event.children_count(:votes_pro)' => -1,
                      'vote_event.children_count(:votes_con)' => 1) do
      post collection_iri(vote_event, :votes, canonical: true),
           params: {
             data: {
               type: 'votes',
               attributes: {
                 side: :con
               }
             }
           },
           headers: argu_headers(accept: :json_api)
    end

    assert_response 201
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.con?
  end

  test 'creator should not put update json_api side' do
    sign_in creator

    assert_difference('Vote.count' => 0,
                      'vote_event.reload.total_vote_count' => 0,
                      'vote_event.children_count(:votes_pro)' => 0,
                      'vote_event.children_count(:votes_con)' => 0) do
      put vote,
          params: {
            data: {
              type: 'votes',
              attributes: {
                side: :con
              }
            }
          },
          headers: argu_headers(accept: :json_api)
    end

    assert_response 204
    assert assigns(:update_service).resource.valid?
    assert assigns(:update_service).resource.pro?
  end

  test 'creator should not delete destroy vote for motion twice' do
    sign_in creator

    assert_difference('Vote.count' => -1,
                      'Edge.count' => -1,
                      'vote_event.reload.children_count(:votes_pro)' => -1) do
      delete vote, headers: argu_headers(accept: :json)
    end

    assert_difference('Vote.count' => 0,
                      'Edge.count' => 0,
                      'vote_event.reload.children_count(:votes_pro)' => 0) do
      delete vote, headers: argu_headers(accept: :json)
    end

    assert_response 404
  end

  test 'creator should delete destroy vote for argument' do
    sign_in creator

    assert_difference('Vote.count' => -1,
                      'Edge.count' => -1,
                      'argument.reload.children_count(:votes_pro)' => -1) do
      delete argument_vote, headers: argu_headers(accept: :json)
    end

    assert_response 204
  end

  test 'creator should delete destroy vote for argument new fe' do
    sign_in creator, Doorkeeper::Application.argu_front_end
    vote_iri = ActsAsTenant.with_tenant(argu) { current_vote_iri(argument) }

    assert_difference('Vote.count' => -1,
                      'Edge.count' => -1,
                      'argument.reload.children_count(:votes_pro)' => -1) do
      delete argument_vote.iri.path, headers: argu_headers(accept: :nq)
    end

    expect_triple(vote_iri, NS::SCHEMA[:option], NS::ARGU[:abstain], NS::ONTOLA[:replace])
    assert_response 200
  end

  test 'creator should delete destroy vote for argument n3' do
    sign_in creator

    assert_difference('Vote.count' => -1,
                      'Edge.count' => -1,
                      'argument.reload.children_count(:votes_pro)' => -1) do
      delete argument_vote.iri.path, headers: argu_headers(accept: :n3)
    end

    assert_response 200
  end

  test 'user should post create for motion with new fe' do
    sign_in user, Doorkeeper::Application.argu_front_end

    expect(vote_event.votes.length).to be 1
    assert_difference('Vote.count' => 1,
                      'Edge.count' => 1,
                      'vote_event.reload.children_count(:votes_con)' => 1) do
      Sidekiq::Testing.inline! do
        post collection_iri(vote_event, :votes, 'filter%5B%5D' => 'option=no', type: :paginated),
             headers: argu_headers(accept: :nq)
      end
    end

    expect_triple(
      resource_iri(vote_event.vote_collection(user_context: context), root: argu),
      NS::AS[:totalItems],
      2,
      NS::ONTOLA[:replace]
    )
    expect_triple(
      resource_iri(vote_event.vote_collection(user_context: context, filter: {option: :yes}), root: argu),
      NS::AS[:totalItems],
      1,
      NS::ONTOLA[:replace]
    )
    expect_triple(
      resource_iri(vote_event.vote_collection(user_context: context, filter: {option: :other}), root: argu),
      NS::AS[:totalItems],
      0,
      NS::ONTOLA[:replace]
    )
    expect_triple(
      resource_iri(vote_event.vote_collection(user_context: context, filter: {option: :no}), root: argu),
      NS::AS[:totalItems],
      1,
      NS::ONTOLA[:replace]
    )

    assert_response 201
  end

  test 'user should post create for motion n3' do
    sign_in user

    assert_difference('Vote.count' => 1,
                      'Edge.count' => 1,
                      'vote_event.reload.children_count(:votes_pro)' => 1) do
      Sidekiq::Testing.inline! do
        post collection_iri(vote_event, :votes),
             params: {vote: {for: :pro}},
             headers: argu_headers(accept: :nq)
      end
    end

    assert_response 201
  end

  private

  def assert_redis_resource_count(count, opts)
    assert_equal count, RedisResource::Relation.where(opts).count
  end
end
