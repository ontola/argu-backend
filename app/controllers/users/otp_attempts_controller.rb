# frozen_string_literal: true

module Users
  class OtpAttemptsController < LinkedRails::Auth::OtpAttemptsController
    skip_before_action :check_if_registered

    private

    def new_resource_from_params
      new_resource
    end

    def handle_expired_session
      @user_id_from_session = User::COMMUNITY_ID

      super
    end
  end
end
