# frozen_string_literal: true

require 'test_helper'

class BannerDismissalsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects

  let(:user) { create(:user) }
  let(:guest_user) { create_guest_user }
  let!(:banner) { create(:banner, parent: argu) }

  test 'guest should post create banner dismissal' do
    sign_in guest_user
    assert_difference_success(:guest_user) do
      Sidekiq::Testing.inline! do
        post collection_iri(banner, :banner_dismissals), headers: argu_headers
      end
    end

    assert_redis_resource_count(1, owner_type: 'BannerDismissal', publisher: guest_user, parent: banner)
    assert_response 201
  end

  test 'user should post create banner dismissal' do
    sign_in user
    assert_difference_success(:user) do
      Sidekiq::Testing.inline! do
        post collection_iri(banner, :banner_dismissals), headers: argu_headers
      end
    end

    assert_redis_resource_count(1, owner_type: 'BannerDismissal', publisher: user, parent: banner)
    assert_response 201
  end

  private

  def assert_difference_success(user_symbol)
    assert_difference(
      'BannerDismissal.count' => 0,
      'Edge.count' => 0,
      'Argu::Redis.keys.count' => 1,
      'Banner.count' => 0,
      "scoped_banners(#{user_symbol}).count" => -1
    ) do
      yield
    end
  end

  def scoped_banners(user)
    ActsAsTenant.with_tenant(argu) do
      token = Doorkeeper::AccessToken.new(scopes: user.guest? ? [:guest] : [:user])
      Pundit.policy_scope(UserContext.new(doorkeeper_token: token, user: user), Banner.all)
    end
  end
end
