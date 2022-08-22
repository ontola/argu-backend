# frozen_string_literal: true

require 'test_helper'

class MotionsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let(:question) do
    create(
      :question,
      :with_follower,
      parent: freetown,
      creator: create(:profile_direct_email)
    )
  end
  let(:question_requires_location) do
    create(
      :question,
      :with_follower,
      parent: freetown,
      require_location: true,
      creator: create(:profile_direct_email)
    )
  end
  let(:subject) do
    create(:motion,
           :with_arguments,
           :with_votes,
           publisher: creator,
           parent: question)
  end
  let(:draft_motion) do
    create(
      :motion,
      publisher: creator,
      parent: question,
      argu_publication_attributes: {draft: true}
    )
  end
  let(:motion_with_placement) do
    create(:motion,
           placement_attributes: {
             lat: 1.0,
             lon: 1.0
           },
           publisher: creator,
           parent: question)
  end
  let(:motion_placement) { motion_with_placement.placement }
  let(:guest_user) { create_guest_user }
  let(:other_guest_user) { create_guest_user(session_id: 'other_id') }
  let(:guest_vote) do
    create(:vote,
           parent: subject.default_vote_event,
           creator: guest_user.profile,
           publisher: guest_user)
  end

  test 'guest should not get other guest_vote included' do
    sign_in other_guest_user
    guest_vote
    get subject, headers: argu_headers(accept: :nq)
    parent_segments = split_iri_segments(subject.default_vote_event.iri.path)
    expect(rdf_body.subjects).not_to(
      include(RDF::URI(expand_uri_template(:vote_iri, parent_iri: parent_segments, with_hostname: true)))
    )
  end

  test 'initiator should post create motion with latlon' do
    sign_in initiator

    Thread.current[:mock_searchkick] = false

    general_create(
      results: {should: true, response: :created},
      parent: :freetown,
      attributes: {
        placement_attributes: {
          lat: 1.0,
          lon: 1.0,
          zoom_level: 1
        }
      },
      differences: [['Motion', 1], ['Placement', 1], ['Activity', 2]]
    )

    Thread.current[:mock_searchkick] = true

    assert_equal 1, Motion.last.placement.lat
    assert_equal 1, Motion.last.placement.lon
    assert_equal 1, Motion.last.placement.zoom_level
  end

  test 'initiator should get new motion object with latlon from filter' do
    sign_in initiator

    filter = {
      NS.schema.latitude => 1,
      NS.schema.longitude => 2,
      NS.ontola[:zoomLevel] => 3
    }
    object = freetown.collection_iri(:motions, type: :paginated, filter: filter).to_s.sub('/m', '/m/new/action_object')
    get object,
        headers: argu_headers(accept: :nq)
    assert_response(:success)
    same_as = expect_triple(RDF::URI(object), NS.owl.sameAs, nil).first.object
    location = expect_triple(same_as, NS.schema.location, nil).first.object
    expect_triple(location, NS.schema.latitude, BigDecimal(1))
    expect_triple(location, NS.schema.longitude, BigDecimal(2))
    expect_triple(location, NS.ontola[:zoomLevel], 3)
  end

  test 'initiator should post create motion with latlon from filter' do
    sign_in initiator

    filter = {
      NS.schema.latitude => 1,
      NS.schema.longitude => 2,
      NS.ontola[:zoomLevel] => 3
    }
    Thread.current[:mock_searchkick] = false
    assert_difference('Motion.count' => 1, 'Placement.count' => 1, 'Activity.count' => 1) do
      post freetown.collection_iri(:motions, type: :paginated, filter: filter),
           headers: argu_headers(accept: :nq),
           params: {motion: default_create_attributes}

      assert_response(:created)
    end
    Thread.current[:mock_searchkick] = true

    assert_equal 1, Motion.last.placement.lat
    assert_equal 2, Motion.last.placement.lon
    assert_equal 3, Motion.last.placement.zoom_level
  end

  test 'initiator should not post create motion without latlon in question requiring location' do
    sign_in initiator

    general_create(
      results: {should: false, response: :unprocessable_entity},
      parent: :question_requires_location,
      differences: [['Motion', 0], ['Activity', 0]]
    )
  end

  test 'initiator should not post create motion with empty latlon in question requiring location' do
    sign_in initiator

    general_create(
      attributes: {
        placement_attributes: {
          id: '',
          lat: '',
          lon: '',
          zoom_level: '1'
        }
      },
      results: {should: false, response: :unprocessable_entity},
      parent: :question_requires_location,
      differences: [['Motion', 0], ['Activity', 0]]
    )
  end

  test 'initiator should post create motion with latlon in question requiring location' do
    sign_in initiator

    general_create(
      attributes: {
        placement_attributes: {
          id: '',
          lat: 2.0,
          lon: 2.0,
          zoom_level: '1'
        }
      },
      results: {should: true, response: :created},
      parent: :question_requires_location,
      differences: [['Motion', 1], ['Activity', 2]]
    )
  end

  test 'creator should put update motion change latlon' do
    sign_in creator

    general_update(
      results: {should: true, response: :success},
      record: :motion_with_placement,
      attributes: {
        placement_attributes: {
          id: motion_placement.id,
          lat: 2.0,
          lon: 2.0
        }
      },
      differences: [['Motion', 0], ['Placement', 0], ['Activity', 1]]
    )

    motion_placement.reload
    assert_equal 2, motion_placement.lat
    assert_equal 2, motion_placement.lon

    expect_triple(resource_iri(motion_placement), NS.sp.Variable, NS.sp.Variable, NS.ontola[:invalidate])
    vote_event_iri = resource_iri(motion_with_placement.default_vote_event)
    expect_triple(vote_event_iri, NS.sp.Variable, NS.sp.Variable, NS.ontola[:invalidate])
    refute_triple(resource_iri(motion_with_placement), NS.sp.Variable, NS.sp.Variable, NS.ontola[:invalidate])
  end

  test 'creator should put update motion remove latlon' do
    sign_in creator

    general_update(
      results: {should: true, response: :success},
      record: :motion_with_placement,
      attributes: {
        placement_attributes: {
          id: motion_placement.id,
          _destroy: 'true'
        }
      },
      differences: [['Motion', 0], ['Placement', -1], ['Activity', 1]]
    )
  end

  let(:staff) { create(:user, :staff) }

  test 'staff should put update motion pin' do
    sign_in staff

    general_update(
      results: {should: true, response: :success},
      attributes: {pinned: true},
      differences: [['Motion.where(pinned_at: nil)', -1]]
    )
  end

  test 'staff should trash draft' do
    sign_in staff
    draft_motion
    assert_difference('Motion.count' => 0, 'Motion.trashed.count' => 1, 'Activity.count' => 1) do
      delete draft_motion
    end
  end

  test 'staff should trash invalid draft' do
    sign_in staff
    draft_motion.properties.destroy_all
    draft_motion.update(cached_properties: {})
    draft_motion.cache_properties
    assert_not draft_motion.reload.valid?
    assert_difference('Motion.count' => 0, 'Motion.trashed.count' => 1, 'Activity.count' => 1) do
      delete draft_motion
    end
  end

  test 'staff should destroy motion' do
    sign_in staff
    motion_with_placement
    assert_difference('Motion.count' => -1, 'Activity.count' => 1) do
      delete motion_with_placement.iri(destroy: true)
    end
  end

  test 'staff should destroy invalid motion' do
    sign_in staff
    motion_with_placement.properties.destroy_all
    motion_with_placement.update(cached_properties: {})
    motion_with_placement.cache_properties
    assert_not motion_with_placement.reload.valid?
    assert_difference('Motion.count' => -1, 'Activity.count' => 1) do
      delete motion_with_placement.iri(destroy: true)
    end
  end
end
