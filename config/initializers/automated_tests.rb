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
      guest: {should: false, response: 302, asserts: ['assigns(:_not_a_user_caught)']},
      user: {should: false, response: 403, asserts: ['assigns(:_not_a_member_caught)']},
      member: {should: true, response: 200},
      moderator: {should: true, response: 200},
      manager: {should: true, response: 200},
      owner: {should: true, response: 200},
      staff: {should: true, response: 200}
    },
    create: {
      guest: {should: false, response: 302, asserts: ['assigns(:_not_a_user_caught)'],
              analytics: false},
      user: {should: false, response: 403, asserts: ['assigns(:_not_a_member_caught)'],
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
      guest: {should: false, response: 302, asserts: ['assigns(:_not_a_user_caught)']},
      user: {should: false, response: 403, asserts: ['assigns(:_not_a_member_caught)']},
      member: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      creator: {should: true, response: 200},
      moderator: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      manager: {should: true, response: 200},
      owner: {should: true, response: 200},
      staff: {should: true, response: 200}
    },
    update: {
      guest: {should: false, response: 302, asserts: ['assigns(:_not_a_user_caught)']},
      user: {should: false, response: 403, asserts: ['assigns(:_not_a_member_caught)']},
      member: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      creator: {should: true, response: 302},
      moderator: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      manager: {should: true, response: 302},
      owner: {should: true, response: 302},
      staff: {should: true, response: 302}
    },
    trash: {
      guest: {should: false, response: 302, asserts: ['assigns(:_not_a_user_caught)'],
              analytics: false},
      user: {should: false, response: 403, asserts: ['assigns(:_not_a_member_caught)'],
             analytics: false},
      member: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)'],
               analytics: false},
      moderator: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)'],
                  analytics: false},
      manager: {should: true, response: 302},
      owner: {should: true, response: 302},
      staff: {should: true, response: 302}
    },
    destroy: {
      guest: {should: false, response: 302, asserts: ['assigns(:_not_a_user_caught)'],
              analytics: false},
      user: {should: false, response: 403, asserts: ['assigns(:_not_a_member_caught)'],
             analytics: false},
      member: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)'],
               analytics: false},
      moderator: {should: false, response: 302, analytics: false},
      manager: {should: true, response: 302},
      owner: {should: true, response: 302},
      staff: {should: true, response: 302}
    },
    move: {
      guest: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      user: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      member: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      moderator: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      manager: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      owner: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      staff: {should: true, response: 200}
    },
    move!: {
      guest: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      user: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      member: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      moderator: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      manager: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      owner: {should: false, response: 302, asserts: ['assigns(:_not_authorized_caught)']},
      staff: {should: true, response: 302}
    }
  }.freeze
end
