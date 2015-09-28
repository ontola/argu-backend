require 'test_helper'

class AccessTokenSignupTest < ActionDispatch::IntegrationTest

  test 'should redirect to root when accessing a forum without an access token' do
    get forum_path(forums(:hidden))
    assert_not assigns(:items), 'render not interrupted with an NotLoggedInException'
    assert_response 404, 'Existence of hidden forums is leaked'
  end

  test 'should not view forum when access tokens are disabled' do
    get forum_path(forums(:super_hidden), at: access_tokens(:token_super_hidden).access_token)
    assert_response 404
  end

  test 'should view forum with an access token' do
    get forum_path(forums(:hidden), at: access_tokens(:token_hidden).access_token)
    assert_response :success
  end

  test 'should update counters accordingly' do
    assert_differences [['access_tokens(:token_hidden).reload.sign_ups', 0],
                        ['access_tokens(:token_hidden).reload.usages', 1]] do
      get forum_path(forums(:hidden), at: access_tokens(:token_hidden).access_token)
    end
    assert_response :success

    assert_differences [['access_tokens(:token_hidden).reload.sign_ups', 0],
                        ['access_tokens(:token_hidden).reload.usages', 0]],
                        'Usages or sign_ups counter changed on secondary get w/ token' do
      get forum_path(forums(:hidden), at: access_tokens(:token_hidden).access_token)
      assert_response :success
    end

    assert_differences [['access_tokens(:token_hidden).reload.sign_ups', 0],
                        ['access_tokens(:token_hidden).reload.usages', 0]] do
      post forum_memberships_path(forums(:hidden), r: forum_path(forums(:hidden)), at: access_tokens(:token_hidden).access_token)
    end
    assert_redirected_to new_user_session_path(r: forum_path(forums(:hidden)))

    follow_redirect!
    assert_response 200

    assert_differences [['User.count', 1],
                        ['access_tokens(:token_hidden).reload.sign_ups', 1],
                        ['access_tokens(:token_hidden).reload.usages', 0]] do
      post user_registration_path, {user: {
                                     shortname_attributes: {shortname: 'newuser'},
                                     email: 'newuser@example.com',
                                     password: 'useruser',
                                     password_confirmation: 'useruser',
                                     r: forums(:hidden).url
                                 },
                                    at: access_tokens(:token_hidden).access_token}
    end
  end

  # Note: The :at params are duplicated everywhere because integration tests apparently don't support session variables
  test 'should register and become a member with an access token' do
    hidden_forum_path = forum_path(forums(:hidden).url)

    get forum_path(forums(:hidden).url, at: access_tokens(:token_hidden).access_token)
    assert_response :success

    post forum_memberships_path(forums(:hidden).url,
                                r: hidden_forum_path,
                                at: access_tokens(:token_hidden).access_token)
    assert_redirected_to new_user_session_path(r: hidden_forum_path)

    follow_redirect!
    assert_response 200

    registration_url = new_user_registration_url(r: hidden_forum_path)
    assert_equal registration_url,
                 document_root_element.css('.btn.btn--argu').attribute('href').to_s

    get registration_url
    assert_response 200

    assert_difference 'User.count', 1 do
      post user_registration_path,
           {user: {
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


    put profile_path('newuser'),
        {profile: {
            profileable_attributes: {
                first_name: 'new',
                last_name: 'user'
            },
            about: 'Something ab'
        }}
    assert_redirected_to hidden_forum_path
    assert assigns(:resource)
    assert assigns(:profile)
    assert_equal 1, assigns(:profile).memberships.count
  end

  test 'should register and become a member with an access token and preserve vote' do
    get forum_path(forums(:hidden).url,
                   at: access_tokens(:token_hidden).access_token)
    assert_response :success

    post motion_vote_path(motions(:hidden_one), 'neutral')
    redirect_url = new_motion_vote_path(motion_id: motions(:hidden_one).id,
                                        vote: {for: :neutral},
                                        confirm: true)
    assert_redirected_to new_user_session_path(r: redirect_url)
    follow_redirect!

    get new_user_registration_path(r: redirect_url)

    assert_difference 'User.count', 1 do
      post user_registration_path,
           {user: {
               shortname_attributes: {shortname: 'newuser'},
               email: 'newuser@example.com',
               password: 'useruser',
               password_confirmation: 'useruser',
               r: redirect_url
           },
            at: access_tokens(:token_hidden).access_token}
    end
    assert_redirected_to edit_user_url('newuser')
    follow_redirect!


    put profile_path('newuser'),
        {profile: {
            profileable_attributes: {
                first_name: 'new',
                last_name: 'user'
            },
            about: 'Something ab'
        }}
    assert_redirected_to redirect_url
    assert assigns(:resource)
    assert assigns(:profile)
    assert_equal 'new user', assigns(:profile).display_name
    assert_equal 1, assigns(:profile).memberships.count

    follow_redirect!

    assert_difference 'Vote.count', 1 do
      url = document_root_element.css('.btns-opinion form:first').attribute('action').to_s
      vote_for = document_root_element.css('.btns-opinion form:first').css('#vote_for').attribute('value').to_s
      post "#{url}?for=#{vote_for}"
      assert_redirected_to motion_url(motions(:hidden_one))
    end

    follow_redirect!
    assert_response :success
  end

end
