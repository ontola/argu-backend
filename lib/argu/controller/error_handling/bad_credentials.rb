# frozen_string_literal: true

module Argu
  module Controller
    module ErrorHandling
      module BadCredentials
        extend ActiveSupport::Concern

        included do
          rescue_from Argu::Errors::AccountLocked, with: :handle_error
          rescue_from Argu::Errors::UnknownEmail, with: :handle_error
          rescue_from Argu::Errors::WrongPassword, with: :handle_error
          rescue_from Argu::Errors::NoPassword, with: :handle_error
        end
      end
    end
  end
end
