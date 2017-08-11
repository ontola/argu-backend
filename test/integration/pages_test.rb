# frozen_string_literal: true
require 'test_helper'

class PagesTest < ActionDispatch::IntegrationTest
  let!(:page) { create(:page) }
  let(:page_non_public) { create(:page, visibility: Page.visibilities[:closed]) }
  let(:freetown) { create_forum(name: 'freetown', page: page) }
  let(:cairo) { create_forum(name: 'cairo', page: page_non_public) }

  let(:motion) do
    create(:motion,
           parent: cairo.edge,
           creator: page.profile,
           publisher: page.owner.profileable)
  end
  let(:argument) do
    create(:argument,
           parent: motion.edge,
           creator: page.profile,
           publisher: page.owner.profileable)
  end

  let(:comment) do
    create(:comment,
           parent: argument.edge,
           creator: page.profile,
           publisher: page.owner.profileable)
  end

  let(:project) do
    create(:project,
           parent: cairo.edge,
           creator: page.profile,
           publisher: page.owner.profileable)
  end

  let(:project_motion) do
    create(:motion,
           parent: project.edge,
           creator: page.profile,
           publisher: page.owner.profileable)
  end

  let(:project_argument) do
    create(:argument,
           parent: project_motion.edge,
           creator: page.profile,
           publisher: page.owner.profileable)
  end

  def init_cairo_with_content
    [cairo, motion, argument, comment, project, project_motion, project_argument]
  end

  test 'should redirect p to o' do
    get "/p/#{page.url}"

    assert_redirected_to page_url(page)
    assert_redirected_to "/o/#{page.url}"
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
               shortname_attributes: {
                 shortname: 'UtrechtNumberTwo'
               },
               last_accepted: '1'
             }
           }
    end
    assert_not_a_user
  end

  test 'guest should get show when public' do
    get page_path(page)

    assert_response 200
  end

  test 'guest should not get show when not public' do
    get page_path(page_non_public)

    assert_response 403
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

    assert_difference('Page.count') do
      post pages_path,
           params: {
             page: {
               profile_attributes: {
                 name: 'Utrecht Two',
                 about: 'Utrecht Two bio'
               },
               shortname_attributes: {
                 shortname: 'UtrechtNumberTwo'
               },
               last_accepted: '1'
             }
           }
    end
    assert_redirected_to settings_page_path(Page.last, tab: :profile)
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
               shortname_attributes: {
                 shortname: 'shortnmae'
               },
               last_accepted: '1'
             }
           }
    end
    assert_response 200
  end

  test 'user should get show when public' do
    sign_in user

    get page_path(page)

    assert_response 200
    assert_not_nil assigns(:profile)
  end

  test 'user should not get show when not public' do
    sign_in user

    get page_path(page_non_public)

    assert_response 403
  end

  define_freetown('amsterdam')
  define_freetown('utrecht')
  let(:user2) { create_member(amsterdam, create_member(utrecht)) }

  test 'user should not get settings when not page owner' do
    sign_in user

    get settings_page_path(page)

    assert_response 403
    assert_equal page, assigns(:page)
  end

  test 'user should not update settings when not page owner' do
    sign_in user

    put page_path(page),
        params: {
          page: {
            profile_attributes: {
              id: page.profile.id,
              about: 'new_about'
            }
          }
        }

    assert_response 403
    assert_equal page, assigns(:page)
    assert_equal page.profile.about, assigns(:page).profile.reload.about
  end

  ####################################
  # As Forum member
  ####################################
  let(:forum_member) { create_member(freetown) }
  let(:non_public_forum_member) { create_member(cairo) }

  test 'forum_member should get show when public' do
    sign_in forum_member

    get page_path(page)

    assert_response 200
    assert_not_nil assigns(:profile)
  end

  test 'forum_member should get show when not public' do
    sign_in non_public_forum_member

    get page_path(page_non_public)

    assert_response 200
    assert_not_nil assigns(:profile)
  end

  ####################################
  # As Admin
  ####################################
  test 'super_admin should get settings and all tabs' do
    create(:place, address: {country_code: 'nl'})
    sign_in page.owner.profileable

    get settings_page_path(page)
    assert_response 200
    assert_equal page, assigns(:page)

    %i(profile groups forums advanced).each do |tab|
      get settings_page_path(page, tab: tab)
      assert_response 200
      assert_equal page, assigns(:page)
    end
  end

  test 'super_admin should update settings' do
    sign_in page.owner.profileable

    put page_path(page),
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

    assigns(:page).profile.reload
    assert_equal 2, assigns(:page).profile.media_objects.count
    assert_equal 'profile_photo.png', assigns(:page).profile.default_profile_photo.content_identifier
    assert_equal 'cover_photo.jpg', assigns(:page).profile.default_cover_photo.content_identifier
    assert_redirected_to settings_page_path(page, tab: :profile)
    assert_equal page, assigns(:page)
    assert_equal 'new_about', assigns(:page).profile.about
  end

  test 'super_admin should put update page add latlon' do
    create(:place, address: {country_code: 'nl'})
    sign_in page.owner.profileable

    assert_differences([['Placement.count', 1], ['Place.count', 1]]) do
      put page_path(page),
          params: {
            id: page.url,
            page: {
              edge_attributes: {
                placements_attributes: {
                  '0' => {
                    lat: 2.0,
                    lon: 2.0,
                    placement_type: 'custom'
                  }
                }
              }
            }
          }
    end

    page.edge.reload
    assert_equal 2, page.edge.placements.custom.first.lat
    assert_equal 2, page.edge.placements.custom.first.lon
  end

  test 'super_admin should get new' do
    sign_in page.owner.profileable

    get new_page_path

    assert_response 200

    assert_have_tag response.body, 'section.page-limit-reached'
  end

  test 'super_admin should not post create' do
    sign_in page.owner.profileable

    assert_no_difference('Page.count') do
      post pages_path,
           params: {
             page: {
               profile_attributes: {
                 name: 'Utrecht Two',
                 about: 'Utrecht Two bio'
               },
               shortname_attributes: {
                 shortname: 'UtrechtNumberTwo'
               },
               last_accepted: '1'
             }
           }
    end
    assert_have_tag response.body, 'section.page-limit-reached'
  end

  test 'super_admin should delete destroy and anonimize its content' do
    init_cairo_with_content
    sign_in page.owner.profileable

    assert_differences([['Page.count', -1],
                        ['Argument.anonymous.count', 2],
                        ['Comment.anonymous.count', 1],
                        ['Motion.anonymous.count', 2],
                        ['Project.anonymous.count', 1]]) do
      delete page_path(page),
             params: {
               page: {
                 confirmation_string: 'remove'
               }
             }
    end
  end

  test 'super_admin should delete destroy when page not owns a forum' do
    sign_in page.owner.profileable

    assert_difference('Page.count', -1) do
      delete page_path(page),
             params: {
               page: {
                 confirmation_string: 'remove'
               }
             }
    end
  end

  test 'super_admin should not delete destroy when page owns a forum' do
    sign_in page.owner.profileable
    freetown

    assert_raises(ActiveRecord::InvalidForeignKey) do
      delete page_path(page),
             params: {
               page: {
                 confirmation_string: 'remove'
               }
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
             shortname_attributes: {
               shortname: 'UtrechtNumberTwo'
             },
             last_accepted: '1'
           }
         }

    assigns(:page).profile.reload
    assert_response 302
    assert assigns(:page)
    assert assigns(:page).persisted?
    assert_equal 'profile_photo.png', assigns(:page).profile.default_profile_photo.content_identifier
    assert_equal 'cover_photo.jpg', assigns(:page).profile.default_cover_photo.content_identifier
    assert_equal 2, assigns(:page).profile.media_objects.count
  end
end
