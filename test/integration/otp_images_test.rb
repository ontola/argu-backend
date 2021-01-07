# frozen_string_literal: true

require 'test_helper'

class OtpImagesTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:subject) { user.otp_secret }
  let(:guest_user) { create_guest_user }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:two_fa_user) { create(:two_fa_user) }
  let(:staff) { create(:user, :staff) }

  # SHOW
  test 'guest should not get show otp secret' do
    sign_in guest_user
    otp_image_show(response: :unauthorized)
  end

  test 'user should get show otp secret' do
    sign_in user
    otp_image_show(response: :ok)
  end

  test 'activated user should not get show otp secret' do
    sign_in two_fa_user
    otp_image_show(response: :forbidden)
  end

  private

  def otp_image_show(response: :ok)
    general_show(results: {response: response})
  end

  def record_path(_record)
    '/argu/users/otp_qr'
  end
end
