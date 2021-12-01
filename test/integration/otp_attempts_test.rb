# frozen_string_literal: true

require 'test_helper'
require 'support/oauth_test_helpers'

class OtpAttemptsTest < ActionDispatch::IntegrationTest
  include OauthTestHelpers
  include JWTHelper

  define_freetown
  let(:subject) { user.otp_secret! }
  let(:guest_user) { create_guest_user }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:two_fa_user) { create(:two_fa_user) }
  let(:staff) { create(:user, :staff) }

  # NEW
  test 'guest should get new otp secret with active otp' do
    sign_in guest_user
    otp_attempt_new(should: true)
  end

  test 'guest should get new otp secret with inactive otp' do
    sign_in guest_user
    otp_attempt_new(session_user: user)
  end

  test 'guest should not get new otp secret with expired session' do
    sign_in guest_user
    otp_attempt_new(response: :gone, session_exp: 1.minute.ago)
  end

  test 'user should get new otp secret' do
    sign_in user
    otp_attempt_new(response: :forbidden)
  end

  test 'activated user should not get new otp secret' do
    sign_in two_fa_user
    otp_attempt_new(response: :forbidden)
  end

  test 'staff should not get new otp secret' do
    sign_in staff
    otp_attempt_new(response: :forbidden)
  end

  # CREATE
  test 'guest should create otp secret with active otp and refresh token' do
    sign_in guest_user
    otp_attempt_create(response: :ok)
    assert_empty response.body
    token = response.headers['New-Authorization']
    refresh_token = Doorkeeper::AccessToken.find_by(token: token).refresh_token
    sleep 1
    assert_difference('Doorkeeper::AccessToken.count', 1) do
      refresh_access_token(refresh_token)
    end
    token_response
    assert_difference('Doorkeeper::AccessToken.count', 0) do
      refresh_access_token(refresh_token)
    end
    token_response(error_type: 'invalid_grant')
  end

  test 'guest should not create otp secret with inactive otp' do
    sign_in guest_user
    otp_attempt_create(response: :forbidden, session_user: user)
  end

  test 'guest should not create otp secret with expired session' do
    sign_in guest_user
    otp_attempt_create(response: :gone, session_exp: 1.minute.ago)
  end

  test 'guest should not create otp secret with wrong attempt' do
    sign_in guest_user
    otp_attempt_create(response: :unprocessable_entity, otp_attempt: 'wrong')
  end

  test 'guest should create otp secret with slightly expired attempt' do
    sign_in guest_user
    otp_attempt_create(otp_time: 30.seconds.ago)
  end

  test 'guest should not create otp secret with expired attempt' do
    sign_in guest_user
    otp_attempt_create(response: :unprocessable_entity, otp_time: 2.minutes.ago)
  end

  test 'user should not create otp secret' do
    sign_in user
    otp_attempt_create(response: :forbidden)
  end

  test 'activated user should not create otp secret' do
    sign_in two_fa_user
    otp_attempt_create(response: :forbidden)
  end

  test 'staff should not create otp secret' do
    sign_in staff
    otp_attempt_create(response: :forbidden)
  end

  private

  def create_path(*_args)
    uri = URI('/argu/u/otp_attempt')
    uri.query = {session: @session}.to_param if @session.present?
    uri.to_s
  end

  def new_path(*_args)
    uri = URI('/argu/u/otp_attempt/new')
    uri.query = {session: @session}.to_param if @session.present?
    uri.to_s
  end

  # rubocop:disable Metrics/ParameterLists
  def otp_attempt_create(
    response: :ok,
    session: nil,
    session_user: two_fa_user,
    session_exp: 10.minutes.from_now,
    otp_attempt: nil,
    otp_time: Time.current
  )
    otp_attempt ||= session_user.otp_secret!.otp_code(time: otp_time)

    @session = session || sign_payload({user_id: session_user.id, exp: session_exp.to_i}, 'HS512')
    general_create(
      attributes: {otp_attempt: otp_attempt},
      results: {response: response}
    )
  end
  # rubocop:enable Metrics/ParameterLists

  def otp_attempt_new(
    response: nil,
    session: nil,
    session_user: two_fa_user,
    session_exp: 10.minutes.from_now,
    should: false
  )
    @session = session || sign_payload({user_id: session_user.id, exp: session_exp.to_i}, 'HS512')
    general_new(results: {response: response, should: should})
  end
end
