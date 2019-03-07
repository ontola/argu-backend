# frozen_string_literal: true

module Argu
  module Controller
    module ErrorHandling
      module BadCredentials
        extend ActiveSupport::Concern

        included do
          rescue_from Argu::Errors::AccountLocked, with: :handle_error
          rescue_from Argu::Errors::UnknownEmail, with: :handle_error
          rescue_from Argu::Errors::UnknownUsername, with: :handle_error
          rescue_from Argu::Errors::WrongPassword, with: :handle_error

          def handle_bad_credentials_html(e)
            redirect_to new_user_session_path(r: e.r, show_error: true)
          end

          alias_method :handle_unknown_email_html, :handle_bad_credentials_html
          alias_method :handle_unknown_username_html, :handle_bad_credentials_html
          alias_method :handle_wrong_password_html, :handle_bad_credentials_html
        end
      end
    end
  end
end
