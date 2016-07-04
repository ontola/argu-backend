require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:page) { create(:page) }
  let(:page_non_public) { create(:page, visibility: Page.visibilities[:closed]) }
  let(:freetown) { create_forum(name: 'freetown', page: page_non_public) }
  let(:access_token) { create(:access_token, item: freetown) }

  let(:motion) do
    create(:motion,
           parent: freetown.edge,
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
           parent: freetown.edge,
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

  def init_content
    [freetown, motion, argument, comment, project, project_motion, project_argument]
  end

  ####################################
  # As Guest
  ####################################
  test 'guest should get show when public' do
    get :show, id: page

    assert_response 200
  end

  test 'guest should not get show when not public' do
    get :show, id: page_non_public

    assert_redirected_to root_path
    assert_nil assigns(:collection)
  end

  test 'guest should get show with platform access' do
    get :show, id: page, at: access_token.access_token

    assert_response 200
    assert_not_nil assigns(:profile)
    assert_not_nil assigns(:collection)

    assert assigns(:collection).values.all? { |arr| arr[:collection].all? { |v| v.forum.open? } },
           'Votes of closed fora are visible to non-members'
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get show' do
    sign_in user

    get :show, id: page

    assert_response 200
    assert_not_nil assigns(:profile)
    assert_not_nil assigns(:collection)

    memberships = assigns(:current_profile).memberships.pluck(:forum_id)
    assert assigns(:collection)
             .values
             .all? { |arr| arr[:collection].all? { |v| memberships.include?(v.forum_id) || v.forum.open? } },
           'Votes of closed fora are visible to non-members'
  end

  define_freetown('amsterdam')
  define_freetown('utrecht')
  let(:user2) { create_member(amsterdam, create_member(utrecht)) }

  test 'user should not show all votes' do
    initialize_user2_votes
    sign_in user2

    get :show, id: utrecht.page
    assert_response 200
    assert assigns(:collection)

    assert_not assigns(:collection)[:con][:collection].any?, 'all votes are shown'
    assert_equal utrecht.page.profile.votes_questions_motions.length,
                 assigns(:collection).values.map { |i| i[:collection].length }.inject(&:+),
                 'Not all/too many votes are shown'
  end

  test 'user should not get settings when not page owner' do
    sign_in user

    get :settings, id: page.url

    assert_response 302
    assert_equal page, assigns(:page)
  end

  test 'user should not update settings when not page owner' do
    sign_in user

    put :update,
        id: page.url,
        page: {
          profile_attributes: {
            id: page.profile.id,
            about: 'new_about'
          }
        }

    assert_redirected_to root_path
    assert_equal page, assigns(:page)
    assert_equal page.profile.about, assigns(:page).profile.reload.about
  end

  ####################################
  # As Owner
  ####################################
  test 'owner should get settings when page owner' do
    sign_in page.owner.profileable

    get :settings, id: page.url

    assert_response 200
    assert_equal page, assigns(:page)
  end

  test 'owner should update settings when page owner' do
    sign_in page.owner.profileable

    put :update,
        id: page.url,
        page: {
          profile_attributes: {
            id: page.profile.id,
            name: 'name',
            about: 'new_about',
            default_profile_photo_attributes: {
              id: page.profile.default_profile_photo.id,
              image: uploaded_file_object(Photo, :image, open_file('profile_photo.png'))
            },
            default_cover_photo_attributes: {
                image: uploaded_file_object(Photo, :image, open_file('cover_photo.jpg'))
            }
          }
        }

    assigns(:page).profile.reload
    assert_equal 2, assigns(:page).profile.photos.count
    assert_equal 'profile_photo.png', assigns(:page).profile.default_profile_photo.image_identifier
    assert_equal 'cover_photo.jpg', assigns(:page).profile.default_cover_photo.image_identifier
    assert_redirected_to settings_page_path(page, tab: :general)
    assert_equal page, assigns(:page)
    assert_equal 'new_about', assigns(:page).profile.about
  end

  test 'owner should be able to create only one page' do
    sign_in page.owner.profileable

    post :create, page: {
      profile_attributes: {
        name: 'Utrecht Two',
        about: 'Utrecht Two bio'
      },
      shortname_attributes: {
        shortname: 'UtrechtNumberTwo'
      },
      last_accepted: '1'
    }

    assert_redirected_to root_path
    assert_not assigns(:page)
  end

  test 'owner should delete destroy when page not owns a forum' do
    init_content
    sign_in page.owner.profileable

    assert_differences([['Page.count', -1],
                        ['Argument.anonymous.count', 2],
                        ['Comment.anonymous.count', 1],
                        ['Motion.anonymous.count', 2],
                        ['Project.anonymous.count', 1]]) do
      delete :destroy,
             id: page.shortname.shortname,
             page: {
                 repeat_name: page.shortname.shortname
             }
    end
  end

  test 'owner should not delete destroy when page owns a forum' do
    sign_in page_non_public.owner.profileable
    freetown

    assert_raises(ActiveRecord::InvalidForeignKey) do
      delete :destroy,
             id: page_non_public.shortname.shortname,
             page: {
                 repeat_name: page_non_public.shortname.shortname
             }
    end
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should be able to create a page' do
    sign_in staff

    post :create,
         page: {
           profile_attributes: {
             name: 'Utrecht Two',
             about: 'Utrecht Two bio',
             default_profile_photo_attributes: {
               image: uploaded_file_object(Photo, :image, open_file('profile_photo.png'))
             },
             default_cover_photo_attributes: {
               image: uploaded_file_object(Photo, :image, open_file('cover_photo.jpg'))
             }
           },
           shortname_attributes: {
             shortname: 'UtrechtNumberTwo'
           },
           last_accepted: '1'
         }

    assigns(:page).profile.reload
    assert_response 303
    assert assigns(:page)
    assert assigns(:page).persisted?
    assert_equal 2, assigns(:page).profile.photos.count
    assert_equal 'profile_photo.png', assigns(:page).profile.default_profile_photo.image_identifier
    assert_equal 'cover_photo.jpg', assigns(:page).profile.default_cover_photo.image_identifier
  end

  private

  def initialize_user2_votes
    motion1 = create(:motion, parent: utrecht.edge)
    motion3 = create(:motion, parent: amsterdam.edge, creator: user2.profile)
    argument1 = create(:argument, parent: motion1.edge)
    create(:vote, parent: motion1.edge, for: :neutral)
    create(:vote, parent: motion3.edge, for: :pro)
    create(:vote, parent: argument1.edge, for: :neutral)
  end
end
