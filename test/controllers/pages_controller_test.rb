require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:page) { FactoryGirl.create(:page) }
  let(:page_non_public) { FactoryGirl.create(:page, visibility: Page.visibilities[:closed]) }
  let(:freetown) { FactoryGirl.create(:forum, name: 'freetown', page: page_non_public) }
  let(:access_token) { FactoryGirl.create(:access_token, item: freetown) }

  ####################################
  # As Guest
  ####################################
  test 'should get show when public' do
    get :show, id: page

    assert_response 200
  end

  test 'should not get show when not public' do
    get :show, id: page_non_public

    assert_redirected_to root_path
    assert_nil assigns(:collection)
  end

  test 'should get show with platform access' do
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
  let(:user) { FactoryGirl.create(:user) }

  test 'should get show' do
    sign_in user

    get :show, id: page

    assert_response 200
    assert_not_nil assigns(:profile)
    assert_not_nil assigns(:collection)

    _memberships = assigns(:current_profile).memberships.pluck(:forum_id)
    assert assigns(:collection).values.all? { |arr| arr[:collection].all? { |v| _memberships.include?(v.forum_id) || v.forum.open? } },
           'Votes of closed fora are visible to non-members'
  end

  let(:amsterdam) { FactoryGirl.create(:forum) }
  let(:utrecht) { FactoryGirl.create(:forum) }
  let(:user2) { create_member(amsterdam, create_member(utrecht)) }

  test 'should not show all votes' do
    initialize_user2_votes
    sign_in user2

    get :show, id: utrecht.page
    assert_response 200
    assert assigns(:collection)

    assert_not assigns(:collection)[:con][:collection].any?, 'all votes are shown'
    assert_equal utrecht.page.profile.votes_questions_motions.length,
                 assigns(:collection).values.map {|i| i[:collection].length }.inject(&:+),
                 'Not all/too many votes are shown'
  end

  test 'should not get settings when not page owner' do
    sign_in user

    get :settings, id: page.url

    assert_response 302
    assert_equal page, assigns(:page)
  end

  test 'should not update settings when not page owner' do
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
  test 'should get settings when page owner' do
    sign_in page.owner.profileable

    get :settings, id: page.url

    assert_response 200
    assert_equal page, assigns(:page)
  end

  test 'should update settings when page owner' do
    sign_in page.owner.profileable

    put :update,
        id: page.url,
        page: {
          profile_attributes: {
            id: page.profile.id,
            name: 'name',
            about: 'new_about'
          }
        }

    assert_redirected_to settings_page_path(page, tab: :general)
    assert_equal page, assigns(:page)
    assert_equal 'new_about', assigns(:page).profile.reload.about
  end

  test 'should be able to create only one page' do
    sign_in page.owner.profileable

    post :create, page: {
      profile_attributes: {
        name: 'Utrecht Two',
        about: 'Utrecht Two bio',
      },
      shortname_attributes: {
        shortname: 'UtrechtNumberTwo'
      },
      last_accepted: '1'
    }

    assert_redirected_to root_path
    assert assigns(:page)
    assert assigns(:page).new_record?, "Page is saved when it shouldn't be"
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { FactoryGirl.create(:user, :staff) }

  test 'should be able to create a page' do
    sign_in staff

    post :create,
         page: {
           profile_attributes: {
             name: 'Utrecht Two',
             about: 'Utrecht Two bio',
           },
           shortname_attributes: {
             shortname: 'UtrechtNumberTwo'
           },
           last_accepted: '1'
         }

    assert_response 303
    assert assigns(:page)
    assert assigns(:page).persisted?
  end

  private

  def initialize_user2_votes
    motion1 = FactoryGirl.create(:motion, forum: utrecht)
    motion3 = FactoryGirl.create(:motion, forum: amsterdam, creator: user2.profile)
    argument1 = FactoryGirl.create(:argument, forum: utrecht, motion: motion1)
    FactoryGirl.create(:vote, voteable: motion1, for: :neutral, forum: utrecht)
    FactoryGirl.create(:vote, voteable: motion3, for: :pro, forum: amsterdam)
    FactoryGirl.create(:vote, voteable: argument1, for: :pro, forum: utrecht)
  end

end
