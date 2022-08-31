# frozen_string_literal: true

require 'test_helper'

class ForumsTest < ActionDispatch::IntegrationTest
  define_freetown
  define_holland
  define_cairo(
    'forum_with_placement',
    attributes: {
      url: 'forum_with_placement',
      shortname_attributes: {shortname: 'forum_with_placement'},
      placement_attributes: {
        lat: 1.0,
        lon: 1.0
      }
    }
  )
  define_helsinki

  let(:group) { create(:group, parent: argu) }
  let(:other_group) { create(:group, parent: argu) }
  let(:draft_motion) do
    create(:motion, parent: holland, argu_publication_attributes: {draft: true})
  end
  let(:draft_question) do
    create(:question, parent: holland, argu_publication_attributes: {draft: true})
  end
  let(:motion_in_draft_question) { create(:motion, parent: draft_question) }

  let(:question) { create(:question, parent: holland) }
  let(:motion) { create(:motion, parent: question) }
  let(:motion_in_question) { create(:question, parent: holland) }

  let(:trashed_motion) { create(:motion, trashed_at: Time.current, parent: holland) }
  let(:trashed_question) { create(:question, trashed_at: Time.current, parent: holland) }

  let(:tm) { create(:motion, trashed_at: Time.current, parent: holland) }
  let(:tq) { create(:question, trashed_at: Time.current, parent: holland) }

  ####################################
  # As Guest
  ####################################

  test 'guest should get show by upcased shortname' do
    sign_in :guest_user

    get freetown.iri.to_s.gsub('freetown', 'Freetown'), headers: argu_headers

    assert_response :success
    expect_resource_type(NS.argu[:Forum], iri: freetown.iri)
  end

  test 'guest should get show by upcased page shortname' do
    sign_in :guest_user

    get freetown.iri.to_s.gsub("/#{argu.url}/", "/#{argu.url.upcase}/"), headers: argu_headers
    assert_redirected_to freetown.iri.to_s
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'should not show statistics' do
    sign_in

    get statistics_iri(freetown), headers: argu_headers
    assert_response 403
    assert_not_authorized
  end

  test 'user should not show hidden to non-members' do
    sign_in

    get helsinki, headers: argu_headers
    assert_response 404, 'Hidden forums are visible'
  end

  ####################################
  # As Initiator
  ####################################
  let(:holland_initiator) { create_initiator(holland) }
  let(:helsinki_initiator) { create_initiator(helsinki) }

  test 'initiator should show hidden to members' do
    sign_in helsinki_initiator

    get helsinki, headers: argu_headers
    assert_response :success
  end

  ####################################
  # As Administrator
  ####################################
  let(:forum_pair) { create_forum_administrator_pair(type: :populated_forum) }
  let(:holland_administrator) { create_administrator(holland) }

  test 'administrator should put update' do
    sign_in holland_administrator
    put holland,
        params: {
          forum: {
            name: 'new name',
            bio: 'new bio',
            default_cover_photo_attributes: {
              content: fixture_file_upload(File.expand_path('test/fixtures/cover_photo.jpg'), 'image/jpg')
            }
          }
        },
        headers: argu_headers

    assert_response :success
    expect_triple(
      resource_iri(holland),
      NS.ontola[:coverPhoto],
      resource_iri(holland.default_cover_photo),
      NS.ontola[:replace]
    )
    expect_triple(
      resource_iri(holland.default_cover_photo),
      NS.sp.Variable,
      NS.sp.Variable,
      NS.ontola[:invalidate]
    )

    assert_not_equal holland.updated_at.iso8601(6), holland.reload.updated_at.iso8601(6)
    assert_equal 'new name', holland.name
    assert_equal 'new bio', holland.bio
    assert_equal 'cover_photo.jpg', holland.default_cover_photo.content.filename.to_s
    assert_equal 1, holland.media_objects.count
  end

  test 'administrator should update shortname' do
    sign_in holland_administrator
    assert_includes holland.widgets.discussions.first.resource_iri.first.first, holland.root_relative_iri.to_s
    put holland,
        params: {
          forum: {
            url: 'new_url'
          }
        },
        headers: argu_headers
    assert_response :success
    updated_holland = Forum.find_by(uuid: holland.uuid)
    assert_equal 'new_url', updated_holland.url
    assert(
      updated_holland
        .widgets
        .last
        .resource_iri
        .all? { |iri, _predicate| iri.end_with?('/new_url/discussions?display=grid&type=infinite') }
    )
    assert_includes(
      updated_holland.widgets.discussions.first.resource_iri.first.first,
      updated_holland.root_relative_iri.to_s
    )
    assert_equal "#{updated_holland.parent.iri}/new_url", updated_holland.iri
    updated_holland.custom_actions.map(&:href).all? do |iri|
      iri.match?(%r{#{Regexp.escape(updated_holland.parent.iri)}/new_url})
    end
  end

  test 'administrator should update grants' do
    sign_in holland_administrator
    assert_equal(holland.grants.count, 1)
    public_grant = holland.grants.first

    assert_difference('Grant.count' => 1) do
      put holland,
          params: {
            forum: {
              grants_attributes: {
                '0': {
                  id: public_grant.id,
                  grant_set_id: public_grant.grant_set_id,
                  group_id: public_grant.group_id
                },
                '1': {
                  grant_set_id: GrantSet.participator.id,
                  group_id: group.id
                },
                '2': {
                  group_id: other_group.id
                }
              }
            }
          },
          headers: argu_headers
      assert_response :success
      expect_triple(NS.sp.Variable, NS.ontola[:baseCollection], holland.collection_iri(:grants), NS.ontola[:invalidate])
      expect_triple(NS.sp.Variable, RDF.type, NS.argu['GrantTree::PermissionGroup'], NS.ontola[:invalidate])
    end
  end

  test 'administrator should update remove grant' do
    sign_in holland_administrator
    assert_equal(holland.grants.count, 1)
    public_grant = holland.grants.first

    assert_difference('Grant.count' => -1) do
      put holland,
          params: {
            forum: {
              grants_attributes: {
                '0': {
                  id: public_grant.id,
                  grant_set_id: '',
                  group_id: public_grant.group_id
                }
              }
            }
          },
          headers: argu_headers
      assert_response :success
      expect_triple(NS.sp.Variable, NS.ontola[:baseCollection], holland.collection_iri(:grants), NS.ontola[:invalidate])
      expect_triple(NS.sp.Variable, RDF.type, NS.argu['GrantTree::PermissionGroup'], NS.ontola[:invalidate])
    end
  end

  test 'administrator should show statistics' do
    sign_in holland_administrator

    get statistics_iri(holland), headers: argu_headers
    assert_response 200
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create :user, :staff }
  let(:transfer_to) { create :page }

  test 'staff should show statistics' do
    sign_in staff

    get statistics_iri(freetown), headers: argu_headers
    assert_response :success
  end

  test 'staff should post create forum json_api' do
    sign_in :service

    assert_difference('Forum.count' => 1) do
      post argu.collection_iri(:forums), params: {
        forum: {
          name: 'New forum',
          url: 'new_forum'
        }
      }, headers: argu_headers(accept: :json_api)
    end
    assert_response 201
  end

  test 'staff should delete destory forum with confirmation string' do
    sign_in staff

    assert_difference('Forum.count', -1) do
      delete freetown.iri.path,
             params: {forum: {confirmation_string: 'remove'}},
             headers: argu_headers
    end
  end

  test 'staff should not delete destroy forum without confirmation string' do
    sign_in staff

    assert_difference('Forum.count', 0) do
      delete freetown.iri.path,
             params: {
               forum: {}
             },
             headers: argu_headers
    end
  end

  ####################################
  # As Service
  ####################################
  test 'service should post create forum' do
    sign_in :service

    assert_difference('Forum.count' => 1, 'Widget.discussions.count' => 1) do
      post argu.collection_iri(:forums), params: {
        forum: {
          name: 'New forum',
          url: 'new_forum'
        }
      }, headers: argu_headers(accept: :json)
    end
    iri = "#{Forum.last.iri}/discussions?display=grid&type=infinite"
    assert_equal Forum.last.widgets.last.resource_iri, [[iri, nil]]
  end

  private

  def included_in_items?(item)
    assigns(:children).map(&:identifier).include?(item.identifier)
  end

  def assert_content_visible
    assert included_in_items?(motion),
           'Motions are not visible'
    assert included_in_items?(question),
           'Questions are not visible'
    assert_not included_in_items?(motion_in_question),
               'Question motions are visible'
  end

  def assert_unpublished_content_invisible
    assert_not assigns(:children).any?(&:is_trashed?),
               'Trashed items are visible'
    assert_not included_in_items?(draft_question),
               'Unpublished questions are visible'
    assert_not included_in_items?(draft_motion),
               'Unpublished motions are visible'
    assert_not included_in_items?(motion_in_draft_question),
               "Unpublished questions' motions are visible"
  end

  def secondary_forums
    holland
    helsinki
  end
end
