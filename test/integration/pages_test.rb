# frozen_string_literal: true

require 'test_helper'

class PagesTest < ActionDispatch::IntegrationTest
  let!(:page) { create_page }
  let!(:other_page) { create_page }
  let(:freetown) { create_forum(name: 'freetown', parent: page) }
  let(:second_freetown) { create_forum(name: 'second_freetown', parent: page) }
  let(:helsinki) { create_forum(name: 'second_freetown', parent: page, discoverable: false) }
  define_freetown('amsterdam')
  define_freetown('utrecht')

  let(:motion) do
    create(:motion,
           parent: freetown,
           creator: other_page.profile,
           publisher: other_page.publisher)
  end
  let(:argument) do
    create(:argument,
           parent: motion,
           creator: other_page.profile,
           publisher: other_page.publisher)
  end

  let(:comment) do
    create(:comment,
           parent: argument,
           creator: other_page.profile,
           publisher: other_page.publisher)
  end

  def init_freetown_with_content
    [freetown, motion, argument, comment]
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should get index' do
    sign_in :guest_user

    get collection_iri(nil, :pages, root: other_page)
    assert_response :success
    expect_triple(requested_iri, NS::AS[:totalItems], 1)
  end

  test 'guest should not get new' do
    sign_in :guest_user

    get new_iri(nil, :pages, root: argu)

    assert_disabled_form
  end

  test 'guest should not post create' do
    sign_in :guest_user

    assert_no_difference('Page.count') do
      post collection_iri(argu, :pages),
           params: {
             page: {
               profile_attributes: {
                 name: 'Utrecht Two',
                 about: 'Utrecht Two bio'
               },
               url: 'UtrechtNumberTwo',
               last_accepted: '1'
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

  test 'user should get index' do
    sign_in user

    get collection_iri(nil, :pages, root: other_page)
    assert_response :success
    expect_triple(requested_iri, NS::AS[:totalItems], 1)
  end

  test 'user should get new' do
    sign_in user

    get new_iri(nil, :pages, root: argu)

    assert_enabled_form
  end

  test 'user should post create' do
    sign_in user

    assert_difference(
      'Tenant.count' => 1,
      'Page.count' => 1,
      "Grant.where(group_id: #{Group::STAFF_ID}, grant_set: GrantSet.staff).count" => 1
    ) do
      post collection_iri(argu, :pages),
           params: {
             page: {
               profile_attributes: {
                 name: 'Utrecht Two',
                 about: 'Utrecht Two bio'
               },
               url: 'UtrechtNumberTwo',
               last_accepted: '1'
             }
           }
    end
    assert_response :success
  end

  test 'user should post create with unnested params' do
    sign_in user

    assert_difference(
      'Tenant.count' => 1,
      'Page.count' => 1,
      "Grant.where(group_id: #{Group::STAFF_ID}, grant_set: GrantSet.staff).count" => 1
    ) do
      post collection_iri(argu, :pages),
           params: {
             page: {
               name: 'Utrecht Two',
               about: 'Utrecht Two bio',
               url: 'UtrechtNumberTwo',
               last_accepted: '1'
             }
           }
    end
    assert_response :success
    assert_equal Page.last.profile.name, 'Utrecht Two'
    assert_equal Page.last.profile.about, 'Utrecht Two bio'
  end

  test 'user should not post create invalid' do
    sign_in user

    assert_difference('Page.count', 0) do
      post collection_iri(argu, :pages),
           params: {
             page: {
               profile_attributes: {
                 name: 'a',
                 about: 'bio'
               },
               url: 'shortnmae',
               last_accepted: '1'
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

    about = page.profile.about

    put page,
        params: {
          page: {
            profile_attributes: {
              id: page.profile.id,
              about: 'new_about'
            }
          }
        }

    assert_response 403
    assert_equal about, page.profile.reload.about
  end

  ####################################
  # As Administrator
  ####################################
  let(:administrator) { page.publisher }
  let(:argu_administrator) { argu.publisher }
  let(:other_page_administrator) { other_page.publisher }

  test 'administrator should get index' do
    sign_in administrator

    get collection_iri(nil, :pages, root: other_page)
    assert_response :success
    expect_triple(requested_iri, NS::AS[:totalItems], 1)
  end

  test 'administrator should get settings and all tabs' do
    create(:place, address: {country_code: 'nl'})
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
            profile_attributes: {
              id: page.profile.id,
              name: 'name',
              about: 'new_about',
              default_profile_photo_attributes: {
                id: page.profile.default_profile_photo.id,
                content: fixture_file_upload(File.expand_path('test/fixtures/profile_photo.png'), 'image/png')
              }
            }
          }
        }

    assert_response :success
    page.reload
    assert_equal 1, page.profile.media_objects.count
    assert_equal 'profile_photo.png', page.profile.default_profile_photo.content_identifier
    assert_equal 'new_about', page.profile.about
  end

  test 'administrator should put update page add latlon' do
    create(:place, address: {country_code: 'nl'})
    sign_in administrator

    assert_difference('Placement.count' => 1, 'Place.count' => 1) do
      put page,
          params: {
            id: page.url,
            page: {
              custom_placement_attributes: {
                lat: 2.0,
                lon: 2.0,
                placement_type: 'custom'
              }
            }
          }
    end

    assert_response :success
    page.reload
    assert_equal 2, page.custom_placement.lat
    assert_equal 2, page.custom_placement.lon
  end

  test 'administrator should put update page change homepage' do
    sign_in argu_administrator
    assert_equal CustomMenuItem.pluck(:edge_id).compact.sort, [amsterdam.uuid, utrecht.uuid].sort
    assert_nil argu.primary_container_node

    put argu, params: {id: argu.url, page: {primary_container_node_id: amsterdam.url}}
    argu.reload
    assert_equal argu.primary_container_node, amsterdam
    assert_equal CustomMenuItem.pluck(:edge_id).compact.sort, [utrecht.uuid].sort

    put argu, params: {id: argu.url, page: {primary_container_node_id: utrecht.url}}
    argu.reload
    assert_equal argu.primary_container_node, utrecht
    assert_equal CustomMenuItem.pluck(:edge_id).compact.sort, [amsterdam.uuid].sort
  end

  test 'administrator should put update iri_prefix' do
    freetown
    sign_in argu_administrator

    assert_includes CustomMenuItem.where(resource: argu).first.href, Rails.application.config.host_name
    freetown.widgets.first.resource_iri.all? { |iri| iri.first.include?(Rails.application.config.host_name) }
    put argu, params: {id: argu.url, page: {iri_prefix: 'example.com'}}
    CustomMenuItem.where(resource: argu).where('href IS NOT NULL').each do |item|
      assert_includes(item.href.to_s, 'example.com')
    end
    freetown.widgets.first.reload.resource_iri.all? { |iri| iri.first.include?('example.com') }

    assert_equal argu.tenant.reload.iri_prefix, 'example.com'
  end

  test 'administrator should get new' do
    sign_in administrator

    get new_iri(nil, :pages, root: argu)

    assert_disabled_form(error: I18n.t('pages.limit_reached_amount', amount: 1))
  end

  test 'administrator should not post create' do
    sign_in administrator

    assert_no_difference('Page.count') do
      post collection_iri(argu, :pages),
           params: {
             page: {
               profile_attributes: {
                 name: 'Utrecht Two',
                 about: 'Utrecht Two bio'
               },
               url: 'UtrechtNumberTwo',
               last_accepted: '1'
             }
           }
    end
    assert_response :forbidden
  end

  test 'administrator should delete destroy and anonimize its content' do
    init_freetown_with_content
    sign_in other_page_administrator

    assert_difference('Page.count' => -1,
                      'Tenant.count' => -1,
                      'Argument.anonymous.count' => 1,
                      'Comment.anonymous.count' => 1,
                      'Motion.anonymous.count' => 1) do
      delete other_page,
             params: {
               page: {
                 confirmation_string: 'remove'
               }
             }
    end
  end

  test 'administrator should delete destroy when page not owns a forum' do
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

  test 'administrator should not delete destroy when page owns a forum' do
    sign_in administrator
    freetown

    assert_no_difference('Page.count') do
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

    post collection_iri(argu, :pages),
         params: {
           page: {
             profile_attributes: {
               name: 'Utrecht Two',
               about: 'Utrecht Two bio',
               default_profile_photo_attributes: {
                 content: fixture_file_upload(File.expand_path('test/fixtures/profile_photo.png'), 'image/png')
               }
             },
             url: 'UtrechtNumberTwo',
             last_accepted: '1'
           }
         }

    page = Page.last
    assert_response :success
    assert_equal 'profile_photo.png', page.profile.default_profile_photo.content_identifier
    assert_equal 1, page.profile.media_objects.count
  end

  test 'staff should not post create a page with existing url' do
    sign_in staff

    assert_difference('Page.count' => 0) do
      post collection_iri(argu, :pages),
           params: {
             page: {
               profile_attributes: {
                 name: 'Name'
               },
               url: staff.url,
               last_accepted: '1'
             }
           }, headers: argu_headers(accept: :n3)
    end
    assert_response :unprocessable_entity
  end
end
