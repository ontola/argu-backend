# frozen_string_literal: true

require 'test_helper'

class ManifestsTest < ActionDispatch::IntegrationTest
  define_page
  let(:user) { create(:user) }

  test 'guest should get manifest with expired token' do
    sign_in expired_token(user).token

    get resource_iri(argu.manifest, root: argu)

    assert_response :success
  end

  private

  def expired_token(resource)
    token = doorkeeper_token_for(resource, expires_in: 1)
    sleep 1
    token
  end
end
