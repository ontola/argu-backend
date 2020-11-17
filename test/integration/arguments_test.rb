# frozen_string_literal: true

require 'test_helper'

class ArgumentsTest < ActionDispatch::IntegrationTest
  define_automated_tests_objects
  let(:motion) do
    create(:motion,
           :with_follower,
           parent: freetown,
           creator: create(:user,
                           :follows_reactions_directly,
                           :viewed_notifications_hour_ago)
                      .profile)
  end
  let(:pro) { create(:pro_argument, parent: motion) }
  let(:con) { create(:con_argument, parent: motion) }

  test 'creator should put update con to pro' do
    sign_in con.publisher

    assert_difference('ConArgument.count' => -1, 'ProArgument.count' => 1, 'Edge.count' => 0) do
      put con,
          params: {
            con_argument: {
              pro: :pro
            }
          }
    end

    assert_response :success
  end

  test 'creator should put update pro to con' do
    sign_in pro.publisher

    assert_difference('ConArgument.count' => 1, 'ProArgument.count' => -1, 'Edge.count' => 0) do
      put pro,
          params: {
            pro_argument: {
              pro: :con
            }
          }
    end

    assert_response :success
  end
end
