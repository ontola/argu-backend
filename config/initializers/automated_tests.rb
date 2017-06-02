# frozen_string_literal: true
require 'argu/test_helpers/automated_tests'

Argu::TestHelpers::AutomatedTests.configure do |config|
  config.action_methods = {
    new: :get,
    create: :post,
    show: :get,
    edit: :get,
    update: :put,
    trash: :delete,
    destroy: :delete,
    shift: :get,
    move: :put
  }.freeze

  config.user_types = {
    new: {
      guest: exp_res(response: 302, asserts: [assert_not_a_user]),
      user: exp_res(should: true, response: 200),
      spectator: exp_res(asserts: [assert_not_authorized]),
      member: exp_res(should: true, response: 200),
      non_member: exp_res(asserts: [assert_not_authorized]),
      moderator: exp_res(should: true, response: 200),
      manager: exp_res(should: true, response: 200),
      super_admin: exp_res(should: true, response: 200),
      staff: exp_res(should: true, response: 200)
    },
    create: {
      guest: exp_res(response: 302, asserts: [assert_not_a_user], analytics: false),
      user: exp_res(should: true, response: 302),
      spectator: exp_res(asserts: [assert_not_authorized], analytics: false),
      member: exp_res(should: true, response: 302),
      non_member: exp_res(asserts: [assert_not_authorized], analytics: false),
      moderator: exp_res(should: true, response: 302),
      manager: exp_res(should: true, response: 302),
      super_admin: exp_res(should: true, response: 302),
      staff: exp_res(should: true, response: 302)
    },
    show: {
      guest: exp_res(should: true, response: 200),
      user: exp_res(should: true, response: 200),
      spectator: exp_res(should: true, response: 200),
      member: exp_res(should: true, response: 200),
      non_member: exp_res(asserts: [assert_not_authorized]),
      moderator: exp_res(should: true, response: 200),
      manager: exp_res(should: true, response: 200),
      super_admin: exp_res(should: true, response: 200),
      staff: exp_res(should: true, response: 200)
    },
    edit: {
      guest: exp_res(response: 302, asserts: [assert_not_a_user]),
      user: exp_res(asserts: [assert_not_authorized]),
      spectator: exp_res(asserts: [assert_not_authorized]),
      member: exp_res(asserts: [assert_not_authorized]),
      non_member: exp_res(asserts: [assert_not_authorized]),
      creator: exp_res(should: true, response: 200),
      moderator: exp_res(asserts: [assert_not_authorized]),
      manager: exp_res(should: true, response: 200),
      super_admin: exp_res(should: true, response: 200),
      staff: exp_res(should: true, response: 200)
    },
    update: {
      guest: exp_res(response: 302, asserts: [assert_not_a_user]),
      user: exp_res(asserts: [assert_not_authorized]),
      spectator: exp_res(asserts: [assert_not_authorized]),
      member: exp_res(asserts: [assert_not_authorized]),
      non_member: exp_res(asserts: [assert_not_authorized]),
      creator: exp_res(should: true, response: 302),
      moderator: exp_res(asserts: [assert_not_authorized]),
      manager: exp_res(should: true, response: 302),
      super_admin: exp_res(should: true, response: 302),
      staff: exp_res(should: true, response: 302)
    },
    trash: {
      guest: exp_res(response: 302, asserts: [assert_not_a_user], analytics: false),
      user: exp_res(analytics: false, asserts: [assert_not_authorized]),
      spectator: exp_res(analytics: false, asserts: [assert_not_authorized]),
      member: exp_res(analytics: false, asserts: [assert_not_authorized]),
      non_member: exp_res(analytics: false, asserts: [assert_not_authorized]),
      moderator: exp_res(analytics: false, asserts: [assert_not_authorized]),
      manager: exp_res(should: true, response: 302),
      super_admin: exp_res(should: true, response: 302),
      staff: exp_res(should: true, response: 302)
    },
    destroy: {
      guest: exp_res(response: 302, asserts: [assert_not_a_user], analytics: false),
      user: exp_res(analytics: false, asserts: [assert_not_authorized]),
      spectator: exp_res(analytics: false, asserts: [assert_not_authorized]),
      member: exp_res(analytics: false, asserts: [assert_not_authorized]),
      non_member: exp_res(analytics: false, asserts: [assert_not_authorized]),
      moderator: exp_res(analytics: false, asserts: [assert_not_authorized]),
      manager: exp_res(should: true, response: 302),
      super_admin: exp_res(should: true, response: 302),
      staff: exp_res(should: true, response: 302)
    },
    shift: {
      guest: exp_res(asserts: [assert_not_authorized]),
      user: exp_res(asserts: [assert_not_authorized]),
      spectator: exp_res(asserts: [assert_not_authorized]),
      member: exp_res(asserts: [assert_not_authorized]),
      non_member: exp_res(asserts: [assert_not_authorized]),
      moderator: exp_res(asserts: [assert_not_authorized]),
      manager: exp_res(asserts: [assert_not_authorized]),
      super_admin: exp_res(asserts: [assert_not_authorized]),
      staff: exp_res(should: true, response: 200)
    },
    move: {
      guest: exp_res(asserts: [assert_not_authorized]),
      user: exp_res(asserts: [assert_not_authorized]),
      spectator: exp_res(asserts: [assert_not_authorized]),
      member: exp_res(asserts: [assert_not_authorized]),
      non_member: exp_res(asserts: [assert_not_authorized]),
      moderator: exp_res(asserts: [assert_not_authorized]),
      manager: exp_res(asserts: [assert_not_authorized]),
      super_admin: exp_res(asserts: [assert_not_authorized]),
      staff: exp_res(should: true, response: 302)
    }
  }.freeze
end
