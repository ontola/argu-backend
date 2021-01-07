# frozen_string_literal: true

require 'test_helper'

class OtpSecretsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:subject) { user.otp_secret }
  let(:guest_user) { create_guest_user }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:two_fa_user) { create(:two_fa_user) }
  let(:staff) { create(:user, :staff) }

  # NEW
  test 'guest should not get new otp secret' do
    sign_in guest_user
    otp_secret_new(response: :forbidden)
  end

  test 'user should get new otp secret' do
    sign_in user
    otp_secret_new(response: :ok)
    assert_enabled_form
  end

  test 'activated user should not get new otp secret' do
    sign_in two_fa_user
    otp_secret_new(response: :ok)
    assert_disabled_form(error: 'Two factor authentication is already activated.')
  end

  # CREATE
  test 'guest should not create otp secret' do
    sign_in guest_user
    otp_secret_create(should: false, response: :unauthorized)
  end

  test 'user should create otp secret' do
    sign_in user
    otp_secret_create
  end

  test 'other user should not create otp secret' do
    sign_in other_user
    other_user.otp_secret
    otp_secret_create(should: false, response: :unprocessable_entity)
  end

  test 'user should not create otp secret with wrong otp_attempt' do
    sign_in user
    user.otp_secret
    otp_secret_create(otp_attempt: 'wrong', should: false, response: :unprocessable_entity)
  end

  test 'user should not create otp secret without otp_attempt' do
    sign_in user
    user.otp_secret
    otp_secret_create(otp_attempt: '', should: false, response: :unprocessable_entity)
  end

  test 'user should create otp secret with slightly expired otp_attempt' do
    sign_in user
    otp_secret_create(time: 30.seconds.ago)
  end

  test 'user should not create otp secret with expired otp_attempt' do
    sign_in user
    otp_secret_create(time: 2.minutes.ago, should: false, response: :unprocessable_entity)
  end

  test 'user should not create otp secret with slightly future otp_attempt' do
    sign_in user
    otp_secret_create(time: 30.seconds.from_now, should: false, response: :unprocessable_entity)
  end

  test 'activated user should not create otp secret' do
    sign_in two_fa_user
    otp_secret_create(otp_user: two_fa_user, should: false, response: :forbidden)
  end

  # DELETE
  test 'guest should not get delete otp secret' do
    sign_in guest_user
    otp_secret_delete(response: :forbidden)
  end

  test 'user should get delete otp secret' do
    sign_in user
    otp_secret_delete(response: :ok)
    assert_disabled_form(error: 'Two factor authentication is not yet activated.')
  end

  test 'activated user should get delete otp secret' do
    sign_in two_fa_user
    otp_secret_delete(response: :ok, record: two_fa_user.otp_secret)
    assert_enabled_form
  end

  test 'other user should not get delete otp secret' do
    sign_in other_user
    otp_secret_delete(response: :forbidden)
  end

  test 'staff should get delete otp secret' do
    sign_in staff
    otp_secret_delete(response: :ok)
    assert_disabled_form(error: 'Two factor authentication is not yet activated.')
  end

  test 'staff should get delete otp secret of activated user' do
    sign_in staff
    otp_secret_delete(response: :ok, record: two_fa_user.otp_secret)
    assert_enabled_form
  end

  # DESTROY
  test 'guest should not destroy otp secret' do
    sign_in guest_user
    otp_secret_destroy(response: :unauthorized, should: false)
  end

  test 'user should not destroy otp secret' do
    sign_in user
    otp_secret_destroy(response: :forbidden, should: false)
  end

  test 'activated user should destroy otp secret' do
    sign_in two_fa_user
    otp_secret_destroy(response: :ok, record: two_fa_user.otp_secret)
  end

  test 'other user should not destroy otp secret' do
    sign_in other_user
    otp_secret_destroy(response: :forbidden, should: false)
  end

  test 'staff should destroy otp secret' do
    sign_in staff
    otp_secret_destroy(response: :forbidden, should: false)
  end

  test 'staff should destroy otp secret of activated user' do
    sign_in staff
    otp_secret_destroy(response: :ok, record: two_fa_user.otp_secret)
  end

  private

  def create_path(_parent)
    '/argu/users/otp_secrets'
  end

  def new_path(*_args)
    '/argu/users/otp_secrets/new'
  end

  def otp_secret_create(
    otp_attempt: nil,
    otp_user: user,
    time: Time.current,
    should: true,
    response: :ok
  )
    otp_attempt ||= otp_user.otp_secret.otp_code(time: time)

    general_create(
      attributes: {otp_attempt: otp_attempt},
      results: {should: should, response: response},
      differences: [['OtpSecret', 0], ['OtpSecret.where(active: true)', 1]]
    )
  end

  def otp_secret_delete(response: :ok, record: user.otp_secret)
    general_delete(record: record, results: {response: response})
  end

  def otp_secret_destroy(response: :ok, record: user.otp_secret, should: true)
    general_destroy(
      record: record,
      results: {response: response, should: should},
      differences: [['OtpSecret', -1]]
    )
  end

  def otp_secret_new(response: :ok)
    general_new(results: {response: response})
  end

  def resource_iri(resource)
    super(resource, root: argu)
  end
end
