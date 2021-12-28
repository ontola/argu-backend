# frozen_string_literal: true

require 'test_helper'

class VotesTest < ActionDispatch::IntegrationTest
  define_freetown
  define_cairo
  let(:guest_user) { create_guest_user }
  let(:other_guest_user) { create_guest_user(session_id: 'other_id') }
  let(:closed_question) { create(:question, expires_at: 1.day.ago, parent: freetown) }
  let(:closed_question_motion) { create(:motion, parent: closed_question) }
  let(:closed_question_argument) { create(:pro_argument, parent: closed_question_motion) }
  let(:motion) { create(:motion, parent: freetown) }
  let(:motion2) { create(:motion, parent: freetown) }
  let(:argument) { create(:pro_argument, parent: motion) }
  let(:argument2) { create(:pro_argument, parent: motion) }
  let(:argument3) { create(:pro_argument, parent: motion) }
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
  let(:vote_event) do
    create(:vote_event,
           parent: motion,
           expires_at: 1.day.from_now)
  end
  let(:future_vote_event) do
    create(:vote_event,
           parent: motion,
           starts_at: 1.day.from_now)
  end
  let(:closed_vote_event) do
    create(:vote_event,
           parent: motion,
           expires_at: Time.current)
  end
  let(:creator) { create(:user) }
  let(:profile_hidden_votes) { create(:user, show_feed: false).profile }
  let(:context) { UserContext.new }

  ####################################
  # as Guest
  ####################################
  test 'guest should get show vote by parent' do
    sign_in guest_user
    guest_vote
    get iri_without_id
    assert_response 200

    expect_path(RDF::URI(iri_without_id),
                [NS.owl.sameAs, NS.schema.creator],
                resource_iri(User.guest, root: argu))
    expect_path(RDF::URI(iri_without_id),
                [NS.owl.sameAs, NS.schema.isPartOf],
                vote_event.iri)
  end

  test 'guest should not get show non-existent vote' do
    sign_in guest_user
    guest_vote2
    other_guest_vote
    current_vote = ActsAsTenant.with_tenant(argu) { current_vote_iri(vote_event) }
    get current_vote, headers: argu_headers(accept: :json_api)
    assert_equal parsed_body['data']['attributes']['option'], NS.argu[:abstain].to_s
  end

  test 'guest should post create for motion json' do
    sign_in guest_user
    assert_difference('Vote.count' => 0,
                      'Edge.count' => 0,
                      'Argu::Redis.keys.count' => 1,
                      'vote_event.reload.children_count(:votes_pro)' => 0) do
      Sidekiq::Testing.inline! do
        post vote_event.collection_iri(:votes),
             params: {
               vote: {option: :yes}
             },
             headers: argu_headers(accept: :json)
      end
    end

    assert_redis_resource_count(1, owner_type: 'Vote', publisher: guest_user, parent: vote_event)
    assert_response 201
  end

  test 'guest should post create for motion nq' do
    sign_in guest_user

    expect(vote_event.votes.length).to be 1
    assert_difference('Vote.count' => 0,
                      'Edge.count' => 0,
                      'vote_event.reload.children_count(:votes_con)' => 0) do
      Sidekiq::Testing.inline! do
        post vote_event.collection_iri(
          :votes,
          type: :paginated,
          filter: {NS.schema.option => :no}
        ),
             headers: argu_headers(accept: :nq)
      end
    end

    assert_response 201
  end

  test 'guest should post not create vote for closed motion' do
    sign_in guest_user
    post closed_question_motion.default_vote_event.collection_iri(:votes),
         params: {
           vote: {option: :no}
         },
         headers: argu_headers(accept: :json_api)
    assert_response 403
    current_vote = ActsAsTenant.with_tenant(argu) { current_vote_iri(closed_question_motion.default_vote_event) }
    get current_vote, headers: argu_headers(accept: :json_api)
    assert_equal parsed_body['data']['attributes']['option'], NS.argu[:abstain].to_s
  end

  test 'guest should post not create vote for future motion' do
    sign_in guest_user
    post future_vote_event.collection_iri(:votes),
         params: {
           vote: {option: :no}
         },
         headers: argu_headers(accept: :json_api)
    assert_response 403
    current_vote = ActsAsTenant.with_tenant(argu) { current_vote_iri(closed_question_motion.default_vote_event) }
    get current_vote, headers: argu_headers(accept: :json_api)
    assert_equal parsed_body['data']['attributes']['option'], NS.argu[:abstain].to_s
  end

  test 'guest should post update vote' do
    sign_in guest_user
    guest_vote
    get iri_without_id, headers: argu_headers(accept: :json_api)
    assert_response 200
    assert_equal primary_resource['attributes']['option'], NS.argu[:yes]
    assert_no_difference('Argu::Redis.keys("temporary.*").count') do
      post vote_event.collection_iri(:votes),
           params: {vote: {option: :no}},
           headers: argu_headers(accept: :json_api)
    end
    assert_response 201
    assert_equal primary_resource['attributes']['option'], NS.argu[:no]
    get iri_without_id, headers: argu_headers(accept: :json_api)
    assert_response 200
    assert_equal primary_resource['attributes']['option'], NS.argu[:no]
  end

  test 'guest should delete destroy argument vote' do
    sign_in guest_user
    argument_guest_vote
    assert_difference('Argu::Redis.keys("temporary.*").count', -1) do
      delete iri_without_id(argument, option: %i[yes])
      assert_response :success
    end
  end

  ####################################
  # As Unconfirmed user
  ####################################
  let(:unconfirmed) { create(:unconfirmed_user) }

  test 'unconfirmed should get show vote' do
    sign_in unconfirmed
    unconfirmed_vote
    get iri_without_id
    assert_response 200

    expect_triple(RDF::URI(iri_without_id), NS.owl.sameAs, unconfirmed_vote.iri)
    expect_triple(unconfirmed_vote.iri, NS.schema.isPartOf, vote_event.iri)
    expect_triple(
      unconfirmed_vote.iri,
      NS.schema.creator,
      RDF::URI("#{argu.iri}/u/#{unconfirmed.id}")
    )
  end

  test 'unconfirmed should not get show non-existent vote' do
    sign_in unconfirmed
    other_guest_vote
    unconfirmed_vote2
    current_vote = ActsAsTenant.with_tenant(argu) { current_vote_iri(vote_event) }
    get current_vote, headers: argu_headers(accept: :json_api)
    assert_equal parsed_body['data']['attributes']['option'], NS.argu[:abstain].to_s
  end

  test 'unconfirmed should post create for motion with json' do
    sign_in unconfirmed

    assert_difference('Vote.count' => 1,
                      'Edge.count' => 1,
                      'vote_event.reload.children_count(:votes_pro)' => 0) do
      post vote_event.collection_iri(:votes),
           params: {
             vote: {option: :yes}
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
      post vote_event.collection_iri(:votes),
           params: {
             vote: {option: :yes}
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
      post argument.collection_iri(:votes),
           params: {
             vote: {
               option: :yes
             }
           },
           headers: argu_headers(accept: :json)
    end

    assert_response 201
    assert assigns(:create_service).resource.valid?
  end

  test 'user should post create for motion nq' do
    sign_in user

    expect(vote_event.votes.length).to be 1
    assert_difference('Vote.count' => 1,
                      'Edge.count' => 1,
                      'vote_event.reload.children_count(:votes_con)' => 0,
                      'vote_event.reload.children_count(:votes_pro)' => 1) do
      Sidekiq::Testing.inline! do
        post(
          vote_event.collection_iri(:votes, filter: {NS.schema.option => :yes}),
          headers: argu_headers(accept: :nq)
        )
      end
    end

    assert_response 201
  end

  test 'user should post create json_api' do
    sign_in user

    assert_difference('Vote.count' => 1,
                      'Edge.count' => 1,
                      'vote_event.reload.children_count(:votes_pro)' => 1) do
      post vote_event.collection_iri(:votes),
           params: {
             vote: {
               option: :yes
             }
           },
           headers: argu_headers(accept: :json_api)
    end

    assert_response 201
    assert assigns(:create_service).resource.valid?
    assert assigns(:create_service).resource.yes?
  end

  test 'user should not post create json_api on closed vote_event' do
    sign_in user
    closed_vote_event

    assert_difference('Vote.count' => 0,
                      'Edge.count' => 0,
                      'vote_event.reload.children_count(:votes_pro)' => 0,
                      'closed_vote_event.reload.children_count(:votes_pro)' => 0) do
      post closed_vote_event.collection_iri(:votes),
           params: {
             vote: {
               option: :yes
             }
           },
           headers: argu_headers(accept: :json_api)
    end
    assert_response :forbidden
  end

  ####################################
  # As Creator
  ####################################
  test 'creator should not create unchanged vote for motion json' do
    sign_in creator

    assert_difference('Vote.count' => 0,
                      'vote_event.children_count(:votes_pro)' => 0) do
      post vote_event.collection_iri(:votes),
           params: {
             vote: {
               option: :yes
             }
           },
           headers: argu_headers(accept: :json)
    end

    assert_response 304
    assert assigns(:create_service).resource.valid?
  end

  test 'creator should not create new vote nq' do
    sign_in creator

    assert_difference('Vote.count' => 0,
                      'vote_event.children_count(:votes_pro)' => 0) do
      post vote_event.collection_iri(:votes),
           params: {
             vote: {
               option: :yes
             }
           },
           headers: argu_headers(accept: :nq)
    end

    assert_response 304
    assert assigns(:create_service).resource.valid?
  end

  test 'creator should post update side json' do
    sign_in creator

    assert_difference('Vote.count' => 1,
                      'Vote.untrashed.count' => 0,
                      'Activity.count' => 0,
                      'vote_event.reload.children_count(:votes_pro)' => -1,
                      'vote_event.reload.children_count(:votes_con)' => 1) do
      post vote_event.collection_iri(:votes),
           params: {
             vote: {
               option: :no
             }
           },
           headers: argu_headers(accept: :json)
    end

    assert_response 201
    assert assigns(:create_service).resource.valid?
  end

  test 'creator should not delete destroy vote for motion twice' do
    sign_in creator

    assert_difference('Vote.count' => 0,
                      'Vote.active.count' => -1,
                      'Edge.count' => 0,
                      'vote_event.reload.children_count(:votes_pro)' => -1) do
      delete vote, headers: argu_headers(accept: :json)
    end

    assert_difference('Vote.count' => 0,
                      'Edge.active.count' => 0,
                      'Edge.count' => 0,
                      'vote_event.reload.children_count(:votes_pro)' => 0) do
      delete vote, headers: argu_headers(accept: :json)
    end

    assert_response 204
  end

  test 'creator should delete destroy vote for argument' do
    sign_in creator

    assert_difference('Vote.count' => 0,
                      'Vote.active.count' => -1,
                      'Edge.count' => 0,
                      'argument.reload.children_count(:votes_pro)' => -1) do
      delete argument_vote, headers: argu_headers(accept: :json)
    end

    assert_response 200
  end

  test 'creator should delete destroy vote for argument new fe' do
    sign_in creator
    vote_iri = ActsAsTenant.with_tenant(argu) { current_vote_iri(argument) }

    assert_difference('Vote.count' => 0,
                      'Vote.active.count' => -1,
                      'Edge.count' => 0,
                      'argument.reload.children_count(:votes_pro)' => -1) do
      delete argument_vote.iri.path, headers: argu_headers(accept: :nq)
    end

    expect_triple(vote_iri, NS.schema.option, NS.argu[:abstain], NS.ontola[:replace])
    assert_response 200
  end

  test 'creator should delete destroy vote for argument n3' do
    sign_in creator

    assert_difference('Vote.count' => 0,
                      'Vote.active.count' => -1,
                      'Edge.count' => 0,
                      'argument.reload.children_count(:votes_pro)' => -1) do
      delete argument_vote.iri.path, headers: argu_headers(accept: :n3)
    end

    assert_response 200
  end

  test 'user should post create con for motion nq' do
    sign_in user

    expect(vote_event.votes.length).to be 1
    assert_difference('Vote.count' => 1,
                      'Edge.count' => 1,
                      'vote_event.reload.children_count(:votes_con)' => 1) do
      Sidekiq::Testing.inline! do
        post vote_event.collection_iri(
          :votes,
          type: :paginated,
          filter: {NS.schema.option => :no}
        ),
             headers: argu_headers(accept: :nq)
      end
    end

    assert_response 201
  end

  test 'user should post create pro for motion nq' do
    sign_in user

    assert_difference('Vote.count' => 1,
                      'Edge.count' => 1,
                      'vote_event.reload.children_count(:votes_pro)' => 1) do
      Sidekiq::Testing.inline! do
        post vote_event.collection_iri(:votes),
             params: {vote: {option: :yes}},
             headers: argu_headers(accept: :nq)
      end
    end

    assert_response 201
  end

  private

  def iri_without_id(parent = vote_event, **params)
    iri_from_template(:vote_iri, **params.merge(parent_iri: split_iri_segments(parent.root_relative_iri), root: argu))
  end
end
