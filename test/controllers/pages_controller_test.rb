require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  ####################################
  # As guest
  ####################################
  let!(:page) { FactoryGirl.create(:page) }
  let(:page_non_public) { FactoryGirl.create(:page, visibility: Page.visibilities[:closed]) }

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
    get :show, id: pages(:utrecht), at: access_tokens(:token_hidden).access_token

    assert_response 200
    assert_not_nil assigns(:profile)
    assert_not_nil assigns(:collection)

    assert assigns(:collection).values.all? { |arr| arr[:collection].all? { |v| v.forum.open? } }, 'Votes of closed fora are visible to non-members'
  end

  ####################################
  # As user
  ####################################
  test 'should get show' do
    sign_in users(:user)

    get :show, id: pages(:utrecht)

    assert_response 200
    assert_not_nil assigns(:profile)
    assert_not_nil assigns(:collection)

    _memberships = assigns(:current_profile).memberships.pluck(:forum_id)
    assert assigns(:collection).values.all? { |arr| arr[:collection].all? { |v| _memberships.include?(v.forum_id) || v.forum.open? } }, 'Votes of closed fora are visible to non-members'
  end

  test 'should not show all votes' do
    sign_in users(:user2)

    get :show, id: pages(:utrecht)
    assert_response 200
    assert assigns(:collection)

    assert_not assigns(:collection)[:con][:collection].any?, 'all votes are shown'
    assert_equal pages(:utrecht).profile.votes_questions_motions.length, assigns(:collection).values.map {|i| i[:collection].length }.inject(&:+), 'Not all/too many votes are shown'
  end

  test 'should be able to create only one page' do
    sign_in users(:user_utrecht_owner)

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

  test 'should get settings when page owner' do
    sign_in users(:user_thom)

    get :settings, id: pages(:page_argu).url

    assert_response 200
    assert_equal pages(:page_argu), assigns(:page)
  end

  test 'should update settings when page owner' do
    sign_in users(:user_thom)

    put :update, id: pages(:page_argu).url, page: {
                                              profile_attributes: {
                                                id: pages(:page_argu).profile.id,
                                                about: 'new_about'
                                              }
                                            }

    assert_redirected_to settings_page_path(pages(:page_argu), tab: :general)
    assert_equal pages(:page_argu), assigns(:page)
    assert_equal 'new_about', assigns(:page).profile.reload.about
  end

  test 'should not get settings when not page owner' do
    sign_in users(:user)

    get :settings, id: pages(:page_argu).url

    assert_response 302
    assert_equal pages(:page_argu), assigns(:page)
  end

  test 'should not update settings when not page owner' do
    sign_in users(:user)

    put :update, id: pages(:page_argu).url, page: {
                   profile_attributes: {
                       id: pages(:page_argu).profile.id,
                       about: 'new_about'
                   }
               }

    assert_redirected_to root_path
    assert_equal pages(:page_argu), assigns(:page)
    assert_equal pages(:page_argu).profile.about, assigns(:page).profile.reload.about
  end

  ####################################
  # As staff
  ####################################

  test 'should be able to create a page' do
    sign_in users(:user_thom)

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

    assert_response 303
    assert assigns(:page)
    assert assigns(:page).persisted?
  end

end
