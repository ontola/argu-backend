# frozen_string_literal: true

module Users
  class OtpAttemptsController < LinkedRails::Auth::OtpAttemptsController
    skip_before_action :check_if_registered

    private

    def handle_expired_session
      @user_id_from_session = User::COMMUNITY_ID

      super
    end
  end
end
