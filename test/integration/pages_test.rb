# frozen_string_literal: true

require 'test_helper'

class PagesTest < ActionDispatch::IntegrationTest
  let!(:page) { create(:page) }
  let(:hidden_page) { create(:page, visibility: Page.visibilities[:hidden]) }
  let(:freetown) { create_forum(name: 'freetown', parent: page) }
  let(:second_freetown) { create_forum(name: 'second_freetown', parent: page) }
  let(:helsinki) { create_forum(name: 'second_freetown', parent: page, discoverable: false) }
  let(:cairo) { create_forum(name: 'cairo', parent: hidden_page) }
  let(:second_cairo) { create_forum(name: 'second_cairo', parent: hidden_page) }

  let(:motion) do
    create(:motion,
           parent: cairo,
           creator: page.profile,
           publisher: page.publisher)
  end
  let(:argument) do
    create(:argument,
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

  def init_cairo_with_content
    [cairo, motion, argument, comment]
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should not get new' do
    get new_page_path

    assert_not_a_user
  end

  test 'guest should not post create' do
    assert_no_difference('Page.count') do
      post pages_path,
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

  test 'guest should get show when publi with multiple visible forums' do
    helsinki
    freetown
    second_freetown

    get page

    assert_response 200
  end

  test 'guest should redirect when only one visible forum' do
    helsinki
    freetown

    get page

    assert_redirected_to freetown.iri_path
  end

  test 'guest should not get show when not public' do
    get hidden_page

    assert_response 404
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get new' do
    sign_in user

    get new_page_path

    assert_response 200

    refute_have_tag response.body, 'section.page-limit-reached'
  end

  test 'user should post create' do
    sign_in user

    assert_difference(
      'Page.count' => 1, "Grant.where(group_id: #{Group::STAFF_ID}, grant_set: GrantSet.staff).count" => 1
    ) do
      post pages_path,
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
    assert_redirected_to settings_iri_path(Page.last, tab: :profile)
  end

  test 'user should not post create invalid' do
    sign_in user

    assert_difference('Page.count', 0) do
      post pages_path,
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
    assert_response 200
  end

  test 'user should get show when public' do
    sign_in user

    get page

    assert_response 200
    assert_not_nil assigns(:profile)
  end

  test 'user should not get show when not public' do
    sign_in user

    get hidden_page

    assert_response 404
  end

  define_freetown('amsterdam')
  define_freetown('utrecht')
  let(:user2) { create_initiator(amsterdam, create_initiator(utrecht)) }

  test 'user should not get settings when not page owner' do
    sign_in user

    get settings_iri(page)

    assert_response 403
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
  # As Forum initiator
  ####################################
  let(:forum_initiator) { create_initiator(freetown) }
  let(:non_public_forum_initiator) { create_initiator(cairo) }

  test 'forum_initiator should get show when public when one forum' do
    sign_in forum_initiator

    get page

    assert_redirected_to freetown.iri_path
    assert_not_nil assigns(:profile)
  end

  test 'forum_initiator should get show when not public when one forum' do
    sign_in non_public_forum_initiator

    get hidden_page

    assert_redirected_to cairo.iri_path
    assert_not_nil assigns(:profile)
  end

  test 'forum_initiator should get show when public when multiple forums' do
    second_freetown

    sign_in forum_initiator

    get page

    assert_response 200
    assert_not_nil assigns(:profile)
  end

  test 'forum_initiator should get show when not public when multiple forums' do
    second_cairo

    sign_in non_public_forum_initiator

    get hidden_page

    assert_response 200
    assert_not_nil assigns(:profile)
  end

  ####################################
  # As Administrator
  ####################################
  test 'administrator should get index' do
    sign_in page.publisher

    get pages_user_path(page.publisher)
    assert_response 200
    assert_select '.profile-box', 1
  end

  test 'administrator should get settings and all tabs' do
    create(:place, address: {country_code: 'nl'})
    sign_in page.publisher

    get settings_iri(page)
    assert_response 200

    %i[profile groups forums advanced shortnames].each do |tab|
      get settings_iri(page, tab: tab)
      assert_response 200
    end
  end

  test 'administrator should update settings' do
    sign_in page.publisher

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
              },
              default_cover_photo_attributes: {
                content: fixture_file_upload(File.expand_path('test/fixtures/cover_photo.jpg'), 'image/jpg')
              }
            }
          }
        }

    page.reload
    assert_equal 2, page.profile.media_objects.count
    assert_equal 'profile_photo.png', page.profile.default_profile_photo.content_identifier
    assert_equal 'cover_photo.jpg', page.profile.default_cover_photo.content_identifier
    assert_redirected_to settings_iri_path(page, tab: :profile)
    assert_equal 'new_about', page.profile.about
  end

  test 'administrator should put update page add latlon' do
    create(:place, address: {country_code: 'nl'})
    sign_in page.publisher

    assert_difference('Placement.count' => 1, 'Place.count' => 1) do
      put page,
          params: {
            id: page.url,
            page: {
              placements_attributes: {
                '0' => {
                  lat: 2.0,
                  lon: 2.0,
                  placement_type: 'custom'
                }
              }
            }
          }
    end

    page.reload
    assert_equal 2, page.custom_placements.first.lat
    assert_equal 2, page.custom_placements.first.lon
  end

  test 'administrator should get new' do
    sign_in page.publisher

    get new_page_path

    assert_response 200

    assert_have_tag response.body, 'section.page-limit-reached'
  end

  test 'administrator should not post create' do
    sign_in page.publisher

    assert_no_difference('Page.count') do
      post pages_path,
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
    assert_have_tag response.body, 'section.page-limit-reached'
  end

  test 'administrator should delete destroy and anonimize its content' do
    init_cairo_with_content
    sign_in page.publisher

    assert_difference('Page.count' => -1,
                      'Argument.anonymous.count' => 1,
                      'Comment.anonymous.count' => 1,
                      'Motion.anonymous.count' => 1) do
      delete page,
             params: {
               page: {
                 confirmation_string: 'remove'
               }
             }
    end
  end

  test 'administrator should delete destroy when page not owns a forum' do
    sign_in page.publisher

    assert_difference('Page.count', -1) do
      delete page,
             params: {
               page: {
                 confirmation_string: 'remove'
               }
             }
    end
  end

  test 'administrator should not delete destroy when page owns a forum' do
    sign_in page.publisher
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
    sign_in page.publisher
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

    post pages_path,
         params: {
           page: {
             profile_attributes: {
               name: 'Utrecht Two',
               about: 'Utrecht Two bio',
               default_profile_photo_attributes: {
                 content: fixture_file_upload(File.expand_path('test/fixtures/profile_photo.png'), 'image/png')
               },
               default_cover_photo_attributes: {
                 content: fixture_file_upload(File.expand_path('test/fixtures/cover_photo.jpg'), 'image/jpg')
               }
             },
             url: 'UtrechtNumberTwo',
             last_accepted: '1'
           }
         }

    page = Page.last
    assert_response 302
    assert_equal 'profile_photo.png', page.profile.default_profile_photo.content_identifier
    assert_equal 'cover_photo.jpg', page.profile.default_cover_photo.content_identifier
    assert_equal 2, page.profile.media_objects.count
  end
end
