# frozen_string_literal: true

require_relative '../../../lib/argu/errors/expired'

module Users
  class OtpAttemptsController < AuthorizedController
    include JWTHelper

    skip_before_action :check_if_registered

    private

    def create_success
      sign_in(current_resource.user, otp_verified: true)

      head 200
    end

    def new_resource_from_params
      attempt = OtpAttempt.find_by(user_id: user_id) || OtpAttempt.new
      attempt&.session = session_param
      attempt
    end

    def user_id
      @user_id ||= decode_token(session_param).try(:[], 'user_id') || raise(ActiveRecord::RecordNotFound)
    rescue JWT::ExpiredSignature
      @user_id = User::COMMUNITY_ID

      raise(Argu::Errors::Expired.new(I18n.t('messages.otp_secrets.expired')))
    end

    def session_param
      params.require(:session)
    end
  end
end
