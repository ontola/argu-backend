require 'test_helper'

class OmniauthTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  test 'should sign up with facebook' do
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
      provider: 'facebook',
      uid: '111907595807605',
      credentials: {
          token: 'CAAKvnjt9N54BACAJ6Uj5LFywuhmo5vy2VUyvBqtZAPrZAUH10sy4KgxZAU0mZConMqV9ZB6kO4eZCC3Y822NbZCXdBjZAjUE9ubUscZBZB5WGHn32jIn2NU7UZAVYbAYWcmfg0vutOLZAw3LDs8YE2O5k2Nwde7zzMK1hyBrZC30wvIFnbjoaGegXEZBbL1fyJjGTUBLADCOczzZAHkDhH3mYqJp2y2'
      },
      info: {
        email: 'testuser@example.com',
        first_name: 'First',
        last_name: 'Last'
      },
      extra: {
          raw_info: {
              middle_name: 'Middle'
          }
      }
    })
    Identity.any_instance.stubs(:email).returns('testuser@example.com')
    Identity.any_instance.stubs(:name).returns('First Last')
    Identity.any_instance.stubs(:image_url).returns('')

    get user_omniauth_authorize_path(:facebook)
    assert_redirected_to user_omniauth_callback_path(:facebook)

    follow_redirect!
    assert_redirected_to setup_users_path

    follow_redirect!
    assert_response 200
    assert assigns(:user)

    put setup_users_path,
         user: {
           shortname_attributes: {
             shortname: 'test_user'
           }
         }

    assert_redirected_to root_path
    follow_redirect!
    
    assert_redirected_to forum_path('utrecht')
    follow_redirect!
    assert_response 200
  end

  test 'should sign in with facebook' do
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
        provider: 'facebook',
        uid: '111903726898977',
        credentials: {
            token: 'CAAKvnjt9N54BACAJ6Uj5LFywuhmo5vy2VUyvBqtZAPrZAUH10sy4KgxZAU0mZConMqV9ZB6kO4eZCC3Y822NbZCXdBjZAjUE9ubUscZBZB5WGHn32jIn2NU7UZAVYbAYWcmfg0vutOLZAw3LDs8YE2O5k2Nwde7zzMK1hyBrZC30wvIFnbjoaGegXEZBbL1fyJjGTUBLADCOczzZAHkDhH3mYqJp2y2'
        },
        info: {
            email: 'user_fb_only@argu.co',
            first_name: 'First',
            last_name: 'Last'
        },
        extra: {
            raw_info: {
                middle_name: 'Middle'
            }
        }
    })
    Identity.any_instance.stubs(:email).returns('user_fb_only@argu.co')
    Identity.any_instance.stubs(:name).returns('First Last')
    Identity.any_instance.stubs(:image_url).returns('')

    get user_omniauth_authorize_path(:facebook)
    assert_redirected_to user_omniauth_callback_path(:facebook)
    follow_redirect!
    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to forum_path('utrecht')
  end

  test 'should connect to facebook' do
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
        provider: 'facebook',
        uid: '1119134323213',
        credentials: {
            token: 'CAAKvnjt9N54BACAJ6Uj5LFywuhmo5vy2VUyvBqtZAPrZAUH10sy4KgxZAU0mZConMqV9ZB6kO4eZCC3Y822NbZCXdBjZAjUE9ubUscZBZB5WGHn32jIn2NU7UZAVYbAYWcmfg0vutOLZAw3LDs8YE2O5k2Nwde7zzMK1hyBrZC30wvIFnbjoaGegXEZBbL1fyJjGTUBLADCOczzZAHkDhH3mYqJp2y2'
        },
        info: {
            email: 'user3@argu.co',
            first_name: 'User3',
            last_name: 'Lastname3'
        },
        extra: {
            raw_info: {}
        }
    })
    Identity.any_instance.stubs(:email).returns('user3@argu.co')
    Identity.any_instance.stubs(:name).returns('User3 Lastname3')
    Identity.any_instance.stubs(:image_url).returns('')

    get user_omniauth_authorize_path(:facebook)
    assert_redirected_to user_omniauth_callback_path(:facebook)

    follow_redirect!
    assert_redirected_to connect_user_path(users(:user3), token: identity_token(Identity.find_by(uid: 1119134323213)))

    follow_redirect!
    assert_response 200

    post connect_user_path(users(:user3), token: identity_token(Identity.find_by(uid: 1119134323213))),
         user: {
             password: 'useruser'
         }
    assert_redirected_to root_path
  end

  test 'should not connect different accounts to facebook' do
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
        provider: 'facebook',
        uid: '1119134323213',
        credentials: {
            token: 'CAAKvnjt9N54BACAJ6Uj5LFywuhmo5vy2VUyvBqtZAPrZAUH10sy4KgxZAU0mZConMqV9ZB6kO4eZCC3Y822NbZCXdBjZAjUE9ubUscZBZB5WGHn32jIn2NU7UZAVYbAYWcmfg0vutOLZAw3LDs8YE2O5k2Nwde7zzMK1hyBrZC30wvIFnbjoaGegXEZBbL1fyJjGTUBLADCOczzZAHkDhH3mYqJp2y2'
        },
        info: {
            email: 'user3@argu.co',
            first_name: 'User3',
            last_name: 'Lastname3'
        },
        extra: {
            raw_info: {}
        }
    })
    Identity.any_instance.stubs(:email).returns('user3@argu.co')
    Identity.any_instance.stubs(:name).returns('User3 Lastname3')
    Identity.any_instance.stubs(:image_url).returns('')

    get user_omniauth_authorize_path(:facebook)
    assert_redirected_to user_omniauth_callback_path(:facebook)

    follow_redirect!
    assert_redirected_to connect_user_path(users(:user3), token: identity_token(Identity.find_by(uid: 1119134323213)))

    get connect_user_path(users(:user2), token: identity_token(Identity.find_by(uid: 1119134323213)))
    assert_response 200

    post connect_user_path(users(:user2), token: identity_token(Identity.find_by(uid: 1119134323213))), user: {
                                                                                                          password: 'useruser'
                                                                                                      }
    assert_response 200
    assert_not_equal users(:user2), assigns(:identity).user
    assert_equal nil, assigns(:identity).user
  end

end
