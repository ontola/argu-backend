require 'test_helper'

class AccessTokenTest < ActiveSupport::TestCase

  def access_token
    @access_token ||= access_tokens(:token_hidden)
  end

  def test_valid
    assert access_token.valid?, access_token.errors.to_a.join(',').to_s
  end

end
