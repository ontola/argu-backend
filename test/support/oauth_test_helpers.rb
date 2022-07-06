# frozen_string_literal: true

module OauthTestHelpers
  private

  def expect_error_code(error_code)
    assert_equal(parsed_body['code'], error_code, parsed_body)
  end

  def expect_error_type(error_type)
    assert_equal(parsed_body['error'], error_type, parsed_body)
  end

  def expired_token(resource)
    token = doorkeeper_token_for(resource, expires_in: 1)
    sleep 1
    token
  end

  def oauth_revoke_path
    "/#{argu.url}#{super}"
  end

  def oauth_token_path
    "/#{argu.url}#{super}"
  end

  def post_token_password(name: user.email, password: user.password, scope: 'user', redirect: nil, results: {})
    post_token_password_request(name, password, scope, redirect)

    token = token_response(**results)
    return unless token

    token_user = token['user']
    assert_equal scope, token_user['type']
    token_user
  end

  def post_token_password_request(name, password, scope = 'user', redirect = nil) # rubocop:disable Metrics/MethodLength
    post oauth_token_path,
         headers: argu_headers(accept: :json),
         params: {
           client_id: Doorkeeper::Application.argu.uid,
           client_secret: Doorkeeper::Application.argu.secret,
           username: name,
           password: password,
           grant_type: 'password',
           scope: scope,
           r: redirect
         }
  end

  def refresh_access_token(refresh_token)
    post oauth_token_path,
         headers: argu_headers(accept: :json),
         params: {
           client_id: Doorkeeper::Application.argu.uid,
           client_secret: Doorkeeper::Application.argu.secret,
           grant_type: :refresh_token,
           refresh_token: refresh_token
         }
  end

  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength
  def token_response(error_code: nil, error_type: nil, refresh_token: true, scope: 'user', ttl: 7200)
    if error_code || error_type
      expect_error_type(error_type || 'invalid_grant')
      expect_error_code(error_code) if error_code
      assert_response %w[invalid_client invalid_token].include?(error_type) ? 401 : 400
      assert_nil parsed_body['access_token']
      assert_nil(response.headers['New-Authorization'])
      nil
    else
      assert_response 200

      if scope.nil?
        assert_nil parsed_body['scope']
      else
        assert_equal scope, parsed_body['scope']
      end
      assert_equal 'Bearer', parsed_body['token_type']
      if ttl.nil?
        assert_nil(parsed_body['expires_in'])
      else
        assert (ttl - parsed_body['expires_in']).abs < 10
      end
      assert_not_nil parsed_body['refresh_token'] if refresh_token
      if parsed_body['access_token']
        assert_equal(response.headers['New-Authorization'], parsed_body['access_token'])
        parsed_access_token
      else
        assert_nil(response.headers['New-Authorization'])
        nil
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/MethodLength
end
