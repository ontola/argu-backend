# frozen_string_literal: true

require 'test_helper'

class PagesTest < ActionDispatch::IntegrationTest
  let!(:page) { create_page }
  let(:freetown) { create_forum(name: 'freetown', parent: page) }
  let(:second_freetown) { create_forum(name: 'second_freetown', parent: page) }
  let(:helsinki) { create_forum(name: 'second_freetown', parent: page, discoverable: false) }
  define_freetown('amsterdam')
  define_freetown('utrecht')

  let(:motion) do
    create(:motion,
           parent: freetown,
           creator: page.profile,
           publisher: page.publisher)
  end
  let(:argument) do
    create(:pro_argument,
           parent: motion,
           creator: page.profile,
           publisher: page.publisher)
  end

  let(:comment) do
    create(:comment,
           parent: argument,
           creator: page.profile,
           publisher: page.publisher)
  end

  def init_freetown_with_content
    [freetown, motion, argument, comment]
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should not get new' do
    sign_in :guest_user

    get new_iri(Page.collection_iri(root: argu).path)

    assert_enabled_form
  end

  test 'guest should not post create' do
    sign_in :guest_user

    assert_no_difference('Page.count') do
      post Page.collection_iri(root: argu),
           params: {
             page: {
               name: 'Utrecht Two',
               url: 'UtrechtNumberTwo'
             }
           }
    end
    assert_not_a_user
  end

  test 'guest should get show public' do
    sign_in :guest_user

    get page

    assert_response :success
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get new' do
    sign_in user

    get new_iri(Page.collection_iri(root: argu).path)

    assert_enabled_form
  end

  test 'user should post create' do
    sign_in user

    assert_difference(
      'Tenant.count' => 1,
      'Page.count' => 1,
      'Forum.count' => 1,
      'CustomMenuItem.count' => 2,
      "Grant.where(group_id: #{Group::STAFF_ID}, grant_set: GrantSet.staff).count" => 1
    ) do
      post Page.collection_iri(root: argu),
           params: {
             page: {
               name: 'Utrecht Two',
               url: 'UtrechtNumberTwo'
             }
           }
      assert_response :success
    end
    assert_equal(Page.last.primary_container_node, Forum.last)
  end

  test 'user should post create with unnested params' do
    sign_in user

    assert_difference(
      'Tenant.count' => 1,
      'Page.count' => 1,
      "Grant.where(group_id: #{Group::STAFF_ID}, grant_set: GrantSet.staff).count" => 1
    ) do
      post Page.collection_iri(root: argu),
           params: {
             page: {
               name: 'Utrecht Two',
               url: 'UtrechtNumberTwo'
             }
           }
    end
    assert_response :success
    assert_equal Page.last.reload.name, 'Utrecht Two'
  end

  test 'user should not post create invalid' do
    sign_in user

    assert_difference('Page.count', 0) do
      post Page.collection_iri(root: argu),
           params: {
             page: {
               name: 'a',
               url: 'shortnmae'
             }
           }
    end
    assert_response :unprocessable_entity
  end

  test 'user should get show when public' do
    sign_in user

    get page

    assert_response :success
  end

  test 'user should get settings' do
    sign_in user

    get settings_iri(page)

    assert_response :success
  end

  test 'user should not update settings when not page owner' do
    sign_in user

    name = page.name

    put page,
        params: {
          page: {
            name: 'new name'
          }
        }

    assert_response 403
    assert_equal name, page.reload.name
  end

  ####################################
  # As Administrator
  ####################################
  let(:administrator) { page.publisher }
  let(:argu_administrator) { argu.publisher }

  test 'administrator should get settings and all tabs' do
    sign_in administrator

    get settings_iri(page)
    assert_response :success

    %i[profile groups forums general shortnames].each do |tab|
      get settings_iri(page, tab: tab)
      assert_response :success
    end
  end

  test 'administrator should update settings' do
    sign_in administrator

    put page,
        params: {
          id: page.url,
          page: {
            name: 'name',
            default_profile_photo_attributes: {
              id: page.default_profile_photo.id,
              content: fixture_file_upload(File.expand_path('test/fixtures/profile_photo.png'), 'image/png')
            }
          }
        }

    assert_response :success
    page.reload
    assert_equal 1, page.media_objects.count
    assert_equal 'profile_photo.png', page.default_profile_photo.content.filename.to_s
  end

  test 'administrator should put update page add latlon' do
    sign_in administrator

    assert_difference('Placement.count' => 1) do
      put page,
          params: {
            id: page.url,
            page: {
              placement_attributes: {
                lat: 2.0,
                lon: 2.0
              }
            }
          }
    end

    assert_response :success
    page.reload
    assert_equal 2, page.placement.lat
    assert_equal 2, page.placement.lon
  end

  test 'administrator should put update page change homepage' do
    sign_in argu_administrator
    assert_equal(
      CustomMenuItem.where(root: argu).pluck(:edge_id).compact.sort,
      [argu.uuid, amsterdam.uuid, utrecht.uuid].sort
    )

    put argu, params: {id: argu.url, page: {primary_container_node_id: amsterdam.url}}
    argu.reload
    assert_equal argu.primary_container_node, amsterdam
    assert_equal(
      CustomMenuItem.where(root: argu).pluck(:edge_id).compact.sort,
      [argu.uuid, argu.forums.first.uuid, utrecht.uuid].sort
    )

    put argu, params: {id: argu.url, page: {primary_container_node_id: utrecht.url}}
    argu.reload
    assert_equal argu.primary_container_node, utrecht
    assert_equal(
      CustomMenuItem.where(root: argu).pluck(:edge_id).compact.sort,
      [argu.uuid, argu.forums.first.uuid, amsterdam.uuid].sort
    )
  end

  test 'administrator should put update iri_prefix' do
    freetown
    sign_in argu_administrator

    assert_includes CustomMenuItem.where(resource: argu).first.href.to_s, Rails.application.config.host_name
    freetown.widgets.first.resource_iri.all? { |iri| iri.first.include?(Rails.application.config.host_name) }
    put argu, params: {id: argu.url, page: {iri_prefix: 'example.com'}}
    CustomMenuItem.where(resource: argu).where.not(href: nil).each do |item|
      assert_includes(item.href.to_s, 'example.com')
    end
    freetown.widgets.first.reload.resource_iri.all? { |iri| iri.first.include?('example.com') }

    assert_equal argu.tenant.reload.iri_prefix, 'example.com'
  end

  test 'administrator should get new' do
    sign_in administrator

    get new_iri(Page.collection_iri(root: argu).path)

    assert_disabled_form(error: I18n.t('pages.limit_reached_amount', count: 1))
  end

  test 'administrator should not post create' do
    sign_in administrator

    assert_no_difference('Page.count') do
      post Page.collection_iri(root: argu),
           params: {
             page: {
               name: 'Utrecht Two',
               url: 'UtrechtNumberTwo'
             }
           }
    end
    assert_response :forbidden
  end

  test 'administrator should delete destroy when page owns a forum' do
    sign_in administrator

    assert_difference('Page.count' => -1, 'Tenant.count' => -1) do
      delete page,
             params: {
               page: {
                 confirmation_string: 'remove'
               }
             }
    end
  end

  test 'administrator should not delete destroy page without confirmation' do
    sign_in administrator
    freetown

    assert_difference('Page.count', 0) do
      delete page,
             params: {
               page: {}
             }
    end
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should be able to create a page' do
    sign_in staff

    post Page.collection_iri(root: argu),
         params: {
           page: {
             name: 'Utrecht Two',
             url: 'UtrechtNumberTwo'
           }
         }

    assert_response :success
  end

  test 'staff should not post create a page with existing url' do
    sign_in staff

    assert_difference('Page.count' => 0) do
      post Page.collection_iri(root: argu),
           params: {
             page: {
               name: 'Name',
               url: argu.url
             }
           }, headers: argu_headers(accept: :n3)
    end
    assert_response :unprocessable_entity
  end

  test 'staff should not post create a page without url' do
    sign_in staff

    assert_difference('Page.count' => 0) do
      post Page.collection_iri(root: argu),
           params: {
             page: {
               name: 'Name'
             }
           }, headers: argu_headers(accept: :n3)
    end
    assert_response :unprocessable_entity
  end

  test 'staff should put update a page change url' do
    sign_in staff
    assert_equal argu.url, 'argu'
    assert_equal argu.iri, argu_url('/argu')

    put argu,
        params: {
          page: {
            url: 'newURL'
          }
        }

    assert_response :success
    updated_argu = Page.argu
    assert_equal updated_argu.url, 'newURL'
    assert_equal updated_argu.iri, argu_url('/newURL')
    expect_ontola_action(redirect: argu_url('/newURL'), reload: true)
  end
end
