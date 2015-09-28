require 'test_helper'

class CommentsTest < ActionDispatch::IntegrationTest

  ####################################
  # Not logged in
  ####################################



  ####################################
  # As user
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'should post create a comment' do
    get forum_path(forums(:hidden).url,
                   at: access_tokens(:token_hidden).access_token)
    assert_response :success

    post forum_memberships_path(forums(:hidden).url,
                                r: forum_path(forums(:hidden).url),
                                at: access_tokens(:token_hidden).access_token)
    assert_redirected_to new_user_session_path(r: forum_path(forums(:hidden).url))
    assert assigns(:resource)

    follow_redirect!


    assert_difference 'User.count', 1 do
      post user_registration_path, {user: {
                                     shortname_attributes: {shortname: 'newuser'},
                                     email: 'newuser@example.com',
                                     password: 'useruser',
                                     password_confirmation: 'useruser',
                                     r: forums(:hidden).url
                                 },
                                    at: access_tokens(:token_hidden).access_token}
    end
    assert_not ActionMailer::Base.deliveries.empty?
    assert_redirected_to edit_user_url('newuser')
    follow_redirect!

    put profile_path('newuser'), {profile: {
                                   profileable_attributes: {
                                       first_name: 'new',
                                       last_name: 'user'
                                   },
                                   about: 'Something ab'
                               }}
    assert_redirected_to forum_url(forums(:hidden).url)
    assert assigns(:resource)
    assert assigns(:profile)
    assert_equal 1, assigns(:profile).memberships.count
  end
end
