# frozen_string_literal: true

require 'test_helper'

class TokensTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:guest_user) { GuestUser.new(session: session) }
  let(:other_guest_user) { GuestUser.new(id: 'other_id') }
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:motion2) { create(:motion, parent: freetown.edge) }
  let(:vote) { create(:vote, parent: motion2.default_vote_event.edge, publisher: user) }
  let(:guest_vote) do
    create(:vote, parent: motion.default_vote_event.edge, creator: guest_user.profile, publisher: guest_user)
  end
  let(:guest_vote2) do
    create(:vote, parent: motion2.default_vote_event.edge, creator: guest_user.profile, publisher: guest_user)
  end
  let(:other_guest_vote) do
    create(:vote,
           parent: motion.default_vote_event.edge,
           creator: other_guest_user.profile,
           publisher: other_guest_user)
  end
  let!(:user) { create(:user) }
  let!(:user_without_password) do
    user = create(:user)
    user.update(encrypted_password: '')
    user
  end


  ####################################
  # WITHOUT CREDENTIALS
  ####################################
  test 'Guest should not post create token without credentials' do
    post oauth_token_path

    assert_response 401
  end

  ####################################
  # SUCCESSFUL
  ####################################
  test 'User should post create token with credentials for other domain not storing temp votes' do
    get root_path
    guest_vote
    other_guest_vote

    assert_differences([['Doorkeeper::AccessToken.count', 1], ['Vote.count', 0], ['Favorite.count', 0]]) do
      Sidekiq::Testing.inline! do
        post oauth_token_path,
             headers: {
               HTTP_HOST: 'other.example'
             },
             params: {
               email: user.email,
               password: user.password,
               grant_type: 'password',
               scope: 'user',
               user: {r: forum_path(freetown)}
             }
      end
    end

    assert_response 200
    assert_equal 'user', parsed_body['scope']
    assert_equal 'bearer', parsed_body['token_type']
    assert_equal 1_209_600, parsed_body['expires_in']
    token = JWT.decode(parsed_body['access_token'], nil, false)[0]
    token_user = token['user']
    assert_equal 'user', token_user['type']
    assert_equal user.email, token_user['email']
    assert_equal user.id, token_user['id']
  end

  test 'User should post create token with credentials for Argu domain storing temp votes' do
    get root_path
    guest_vote
    guest_vote2
    other_guest_vote
    vote

    assert_differences([['Doorkeeper::AccessToken.count', 1], ['Vote.count', 1], ['Favorite.count', 0]]) do
      Sidekiq::Testing.inline! do
        post oauth_token_path,
             headers: {
               HTTP_HOST: 'argu.co'
             },
             params: {
               email: user.email,
               password: user.password,
               grant_type: 'password',
               scope: 'user',
               user: {r: forum_path(freetown)}
             }
      end
    end

    assert_redirected_to forum_path(freetown)
  end

  test 'User should post create token with username email for other domain' do
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'other.example'
           },
           params: {
             username: user.email,
             password: user.password,
             grant_type: 'password',
             scope: 'user'
           }
    end
    assert_response 200
  end

  test 'User should post create token with username username for other domain' do
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'other.example'
           },
           params: {
             username: user.url,
             password: user.password,
             grant_type: 'password',
             scope: 'user'
           }
    end
    assert_response 200
  end

  test 'User should post create token with username email for Argu domain' do
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'argu.co'
           },
           params: {
             username: user.email,
             password: user.password,
             grant_type: 'password',
             scope: 'user'
           }
    end
    assert_redirected_to root_path
  end

  test 'User should post create token with username username for Argu domain' do
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'argu.co'
           },
           params: {
             username: user.url,
             password: user.password,
             grant_type: 'password',
             scope: 'user'
           }
    end
    assert_redirected_to root_path
  end

  test 'User should post create token with r for Argu domain' do
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'argu.co'
           },
           params: {
             username: user.url,
             password: user.password,
             grant_type: 'password',
             scope: 'user',
             r: forum_path(freetown)
           }
    end
    assert_redirected_to forum_path(freetown)
  end

  ####################################
  # EMPTY PASSWORD
  ####################################
  test 'User should not post create token with credentials and empty password for other domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'other.example'
           },
           params: {
             email: user_without_password.email,
             password: '',
             grant_type: 'password',
             scope: 'user'
           }
    end
    assert_redirected_to new_user_session_path(show_error: true)
  end

  test 'User should not post create token with credentials and empty password for Argu domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: Rails.application.config.host_name
           },
           params: {
             email: user_without_password.email,
             password: '',
             grant_type: 'password',
             scope: 'user'
           }
    end
    assert_redirected_to new_user_session_path(r: '', show_error: true)
  end

  ####################################
  # WRONG PASSWORD
  ####################################
  test 'User should not post create token with wrong password for other domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'other.example'
           },
           params: {
             email: user.email,
             password: 'wrong',
             grant_type: 'password',
             scope: 'user'
           }
    end
    assert_redirected_to new_user_session_path(show_error: true)
  end

  test 'User should not post create token with wrong password for Argu domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'argu.co'
           },
           params: {
             email: user.email,
             password: 'wrong',
             grant_type: 'password',
             scope: 'user'
           }
    end
    assert_redirected_to new_user_session_path(r: '', show_error: true)
  end

  test 'User should not post create token with wrong password and r for Argu domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'argu.co'
           },
           params: {
             email: user.email,
             password: 'wrong',
             grant_type: 'password',
             scope: 'user',
             r: forum_path(freetown)
           }
    end
    assert_redirected_to new_user_session_path(r: forum_path(freetown), show_error: true)
  end

  ####################################
  # UNKOWN EMAIL
  ####################################
  test 'User should not post create token with unknown email for other domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'other.example'
           },
           params: {
             email: 'wrong@example.com',
             password: 'wrong',
             grant_type: 'password',
             scope: 'user'
           }
    end
    assert_redirected_to new_user_session_path(show_error: true)
  end

  test 'User should not post create token with unknown email for Argu domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'argu.co'
           },
           params: {
             email: 'wrong@example.com',
             password: 'wrong',
             grant_type: 'password',
             scope: 'user'
           }
    end
    assert_redirected_to new_user_session_path(r: '', show_error: true)
  end

  test 'User should not post create token with unknown email and r for Argu domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'argu.co'
           },
           params: {
             email: 'wrong@example.com',
             password: 'wrong',
             grant_type: 'password',
             scope: 'user',
             r: forum_path(freetown)
           }
    end
    assert_redirected_to new_user_session_path(r: forum_path(freetown), show_error: true)
  end

  ####################################
  # UNKOWN USERNAME
  ####################################
  test 'User should not post create token with unknown username for other domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'other.example'
           },
           params: {
             username: 'wrong',
             password: 'wrong',
             grant_type: 'password',
             scope: 'user'
           }
    end
    assert_redirected_to new_user_session_path(show_error: true)
  end

  test 'User should not post create token with unknown username for Argu domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'argu.co'
           },
           params: {
             username: 'wrong',
             password: 'wrong',
             grant_type: 'password',
             scope: 'user'
           }
    end
    assert_redirected_to new_user_session_path(r: '', show_error: true)
  end

  test 'User should not post create token with unknown username and r for Argu domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'argu.co'
           },
           params: {
             username: 'wrong',
             password: 'wrong',
             grant_type: 'password',
             scope: 'user',
             r: forum_path(freetown)
           }
    end
    assert_redirected_to new_user_session_path(r: forum_path(freetown), show_error: true)
  end

  ####################################
  # WITH SERVICE_SCOPE
  ####################################
  test 'User should not post create token with service scope for other domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'other.example'
           },
           params: {
             email: user.email,
             password: user.password,
             grant_type: 'password',
             scope: 'service'
           }
    end
    assert_response 401
  end

  test 'User should not post create token with service scope for Argu domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'argu.co'
           },
           params: {
             email: user.email,
             password: user.password,
             grant_type: 'password',
             scope: 'service'
           }
    end
    assert_response 401
  end

  test 'User should not post create token with user and service scope for other domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'other.example'
           },
           params: {
             email: user.email,
             password: user.password,
             grant_type: 'password',
             scope: 'user service'
           }
    end
    assert_response 401
  end

  test 'User should not post create token with user and service scope for Argu domain' do
    assert_no_difference('Doorkeeper::AccessToken.count') do
      post oauth_token_path,
           headers: {
             HTTP_HOST: 'argu.co'
           },
           params: {
             email: user.email,
             password: user.password,
             grant_type: 'password',
             scope: 'user service'
           }
    end
    assert_response 401
  end

  ####################################
  # As Unconfirmed User
  ####################################
  let(:unconfirmed_user) { create(:user, :unconfirmed) }

  test 'Unconfirmed user should post create token for other domain not transfering temp votes' do
    get root_path
    guest_vote
    other_guest_vote

    assert_differences([['Doorkeeper::AccessToken.count', 1], ['Vote.count', 0], ['Favorite.count', 0]]) do
      Sidekiq::Testing.inline! do
        post oauth_token_path,
             headers: {
               HTTP_HOST: 'other.example'
             },
             params: {
               username: unconfirmed_user.email,
               password: unconfirmed_user.password,
               grant_type: 'password',
               scope: 'user'
             }
      end
    end

    assert_response 200
    assert_empty Argu::Redis.keys("temporary.user.#{User.last.id}.vote.*.#{motion.default_vote_event.edge.path}")
  end

  test 'Unconfirmed user should post create token for Argu domain transfering temp votes' do
    get root_path
    guest_vote
    other_guest_vote

    assert_differences([['Doorkeeper::AccessToken.count', 1], ['Vote.count', 0], ['Favorite.count', 0]]) do
      Sidekiq::Testing.inline! do
        post oauth_token_path,
             headers: {
               HTTP_HOST: 'argu.co'
             },
             params: {
               username: unconfirmed_user.email,
               password: unconfirmed_user.password,
               grant_type: 'password',
               scope: 'user',
               user: {r: forum_path(freetown)}
             }
      end
    end
    assert_redirected_to forum_path(freetown)
    assert_not_empty Argu::Redis.keys("temporary.user.#{User.last.id}.vote.*.#{motion.default_vote_event.edge.path}")
  end
end
