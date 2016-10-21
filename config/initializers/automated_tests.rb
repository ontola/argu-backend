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
    move: :get,
    move!: :put
  }.freeze

  config.user_types = {
    new: {
      guest: {should: false, response: 302, asserts: [assert_not_a_user]},
      user: {should: false, response: 403, asserts: [assert_not_a_member]},
      member: {should: true, response: 200},
      moderator: {should: true, response: 200},
      manager: {should: true, response: 200},
      owner: {should: true, response: 200},
      staff: {should: true, response: 200}
    },
    create: {
      guest: {should: false, response: 302, asserts: [assert_not_a_user],
              analytics: false},
      user: {should: false, response: 403, asserts: [assert_not_a_member],
             analytics: false},
      member: {should: true, response: 302},
      moderator: {should: true, response: 302},
      manager: {should: true, response: 302},
      owner: {should: true, response: 302},
      staff: {should: true, response: 302}
    },
    show: {
      guest: {should: true, response: 200},
      user: {should: true, response: 200},
      member: {should: true, response: 200},
      moderator: {should: true, response: 200},
      manager: {should: true, response: 200},
      owner: {should: true, response: 200},
      staff: {should: true, response: 200}
    },
    edit: {
      guest: {should: false, response: 302, asserts: [assert_not_a_user]},
      user: {should: false, response: 403, asserts: [assert_not_a_member]},
      member: {should: false, response: 302, asserts: [assert_not_authorized]},
      creator: {should: true, response: 200},
      moderator: {should: false, response: 302, asserts: [assert_not_authorized]},
      manager: {should: true, response: 200},
      owner: {should: true, response: 200},
      staff: {should: true, response: 200}
    },
    update: {
      guest: {should: false, response: 302, asserts: [assert_not_a_user]},
      user: {should: false, response: 403, asserts: [assert_not_a_member]},
      member: {should: false, response: 302, asserts: [assert_not_authorized]},
      creator: {should: true, response: 302},
      moderator: {should: false, response: 302, asserts: [assert_not_authorized]},
      manager: {should: true, response: 302},
      owner: {should: true, response: 302},
      staff: {should: true, response: 302}
    },
    trash: {
      guest: {should: false, response: 302, asserts: [assert_not_a_user],
              analytics: false},
      user: {should: false, response: 403, asserts: [assert_not_a_member],
             analytics: false},
      member: {should: false, response: 302, asserts: [assert_not_authorized],
               analytics: false},
      moderator: {should: false, response: 302, asserts: [assert_not_authorized],
                  analytics: false},
      manager: {should: true, response: 302},
      owner: {should: true, response: 302},
      staff: {should: true, response: 302}
    },
    destroy: {
      guest: {should: false, response: 302, asserts: [assert_not_a_user],
              analytics: false},
      user: {should: false, response: 403, asserts: [assert_not_a_member],
             analytics: false},
      member: {should: false, response: 302, asserts: [assert_not_authorized],
               analytics: false},
      moderator: {should: false, response: 302, analytics: false},
      manager: {should: true, response: 302},
      owner: {should: true, response: 302},
      staff: {should: true, response: 302}
    },
    move: {
      guest: {should: false, response: 302, asserts: [assert_not_authorized]},
      user: {should: false, response: 302, asserts: [assert_not_authorized]},
      member: {should: false, response: 302, asserts: [assert_not_authorized]},
      moderator: {should: false, response: 302, asserts: [assert_not_authorized]},
      manager: {should: false, response: 302, asserts: [assert_not_authorized]},
      owner: {should: false, response: 302, asserts: [assert_not_authorized]},
      staff: {should: true, response: 200}
    },
    move!: {
      guest: {should: false, response: 302, asserts: [assert_not_authorized]},
      user: {should: false, response: 302, asserts: [assert_not_authorized]},
      member: {should: false, response: 302, asserts: [assert_not_authorized]},
      moderator: {should: false, response: 302, asserts: [assert_not_authorized]},
      manager: {should: false, response: 302, asserts: [assert_not_authorized]},
      owner: {should: false, response: 302, asserts: [assert_not_authorized]},
      staff: {should: true, response: 302}
    }
  }.freeze
end
