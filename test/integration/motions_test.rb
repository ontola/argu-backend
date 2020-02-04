# frozen_string_literal: true

require 'test_helper'

class MotionsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let(:question) do
    create(:question,
           :with_follower,
           parent: freetown,
           options: {
             creator: create(:profile_direct_email)
           })
  end
  let(:question_requires_location) do
    create(:question,
           :with_follower,
           parent: freetown,
           require_location: true,
           options: {
             creator: create(:profile_direct_email)
           })
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
           custom_placement_attributes: {
             lat: 1.0,
             lon: 1.0,
             placement_type: 'custom'
           },
           publisher: creator,
           parent: question)
  end
  let(:guest_user) { create_guest_user }
  let(:other_guest_user) { create_guest_user(id: 'other_id') }
  let(:guest_vote) do
    create(:vote,
           parent: subject.default_vote_event,
           creator: guest_user.profile,
           publisher: guest_user)
  end

  test 'guest should get guest_vote included' do
    sign_in guest_user
    guest_vote
    get subject, headers: argu_headers(accept: :nq)
    parent_segments = split_iri_segments(subject.default_vote_event.iri_path)
    vote_iri = ActsAsTenant.with_tenant(argu) do
      RDF::DynamicURI(argu_url(expand_uri_template(:vote_iri, parent_iri: parent_segments)))
    end
    expect(response.body).to(include("<#{vote_iri}>"))
  end

  test 'guest should not get other guest_vote included' do
    sign_in other_guest_user
    guest_vote
    get subject, headers: argu_headers(accept: :nq)
    parent_segments = split_iri_segments(subject.default_vote_event.iri.path)
    expect(response.body).not_to(
      include("<#{expand_uri_template(:vote_iri, parent_iri: parent_segments, with_hostname: true)}>")
    )
  end

  test 'initiator should show tutorial only on first post create' do
    sign_in initiator

    general_create(
      parent: :freetown,
      results: {
        should: true,
        response: :created
      }
    )
    assert_not_nil assigns(:create_service).resource
    assert_equal(
      response.headers['Location'],
      argu_url(assigns(:create_service).resource.iri.path, start_motion_tour: true)
    )
    WebMock.reset!

    general_create(
      parent: :freetown,
      results: {
        should: true,
        response: :created
      }
    )
    assert_not_nil assigns(:create_service).resource

    assert_redirected_to assigns(:create_service).resource.iri.path
  end

  test 'initiator should post create motion with latlon' do
    sign_in initiator

    Thread.current[:mock_searchkick] = false

    general_create(
      results: {should: true, response: :created},
      parent: :freetown,
      attributes: {
        custom_placement_attributes: {
          lat: 1.0,
          lon: 1.0,
          zoom_level: 1,
          placement_type: 'custom'
        }
      },
      differences: [['Motion', 1], ['Placement', 1], ['Place', 1], ['Activity', 2]]
    )

    Thread.current[:mock_searchkick] = true

    assert_equal 1, Motion.last.placements.first.lat
    assert_equal 1, Motion.last.placements.first.lon
    assert_equal 1, Motion.last.placements.first.zoom_level
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
        custom_placement_attributes: {
          id: '',
          placement_type: 'custom',
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
        custom_placement_attributes: {
          id: '',
          placement_type: 'custom',
          lat:  2.0,
          lon:  2.0,
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
        custom_placement_attributes: {
          id: motion_with_placement.placements.first.id,
          lat: 2.0,
          lon: 2.0
        }
      },
      differences: [['Motion', 0], ['Placement', 0], ['Place', 1], ['Activity', 1]]
    )

    motion_with_placement.reload
    assert_equal 2, motion_with_placement.placements.first.lat
    assert_equal 2, motion_with_placement.placements.first.lon
  end

  test 'creator should put update motion remove latlon' do
    sign_in creator

    general_update(
      results: {should: true, response: :success},
      record: :motion_with_placement,
      attributes: {
        custom_placement_attributes: {
          id: motion_with_placement.placements.first.id,
          _destroy: 'true'
        }
      },
      differences: [['Motion', 0], ['Placement', -1], ['Place', 0], ['Activity', 1]]
    )
  end

  let(:staff) { create(:user, :staff) }

  test 'staff should trash draft' do
    sign_in staff
    draft_motion
    assert_difference('Motion.count' => 0, 'Motion.trashed.count' => 1, 'Activity.count' => 1) do
      delete draft_motion
    end
  end
end
