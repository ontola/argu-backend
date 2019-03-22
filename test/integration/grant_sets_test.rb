# frozen_string_literal: true

require 'test_helper'

class GrantSetsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }
  let(:staff) { create(:user, :staff) }

  test 'guest not get show grant_set' do
    get grant_set_path('participator')
    assert_not_authorized
  end

  test 'user not get show grant_set' do
    sign_in user
    get grant_set_path('participator')
    assert_not_authorized
  end

  test 'staff get show grant_set' do
    sign_in staff
    checked = []
    checked << should_show_grant_set('spectator', should: 15, should_not: 59)
    checked << should_show_grant_set('participator', should: 19, should_not: 54, conditional: 1)
    checked << should_show_grant_set('initiator', should: 22, should_not: 52)
    checked << should_show_grant_set('moderator', should: 38, should_not: 36)
    checked << should_show_grant_set('administrator', should: 44, should_not: 30)
    checked << should_show_grant_set('staff', should: 55, should_not: 19)
    assert_empty GrantSet::RESERVED_TITLES - checked, "Grantsets #{GrantSet::RESERVED_TITLES - checked} are not tested"
  end

  private

  def should_show_grant_set(title, opts = {})
    get grant_set_path(title)
    assert_response 200
    assert_select '.fa-check.permitted-icon', {count: opts[:should] || 0},
                  "#{title} should have #{opts[:should] || 0} permitted"
    assert_select '.fa-close.permitted-icon', {count: opts[:should_not] || 0},
                  "#{title} should have #{opts[:should_not] || 0} not permitted"
    assert_select '.fa-question.permitted-icon', {count: opts[:conditional] || 0},
                  "#{title} should have #{opts[:conditional] || 0} conditionals"
    title
  end
end
