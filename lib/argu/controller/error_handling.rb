# frozen_string_literal: true

require 'argu/controller/error_handling/data_structures'
require 'argu/controller/error_handling/handlers'
require 'argu/controller/error_handling/helpers'

module Argu
  # The generic Argu error handling code. Currently a mess from different error
  # classes with inconsistent attributes.
  module ErrorHandling
    extend ActiveSupport::Concern

    include DataStructures
    include Handlers
    include Helpers

    included do
      rescue_from Argu::NotAUserError, with: :handle_not_a_user_error
      rescue_from Argu::NotAuthorizedError, with: :handle_not_authorized_error
      rescue_from Argu::UnknownEmailError, with: :handle_bad_credentials
      rescue_from Argu::UnknownUsernameError, with: :handle_bad_credentials
      rescue_from Argu::WrongPasswordError, with: :handle_bad_credentials
      rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
      rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique
      rescue_from ActiveRecord::StaleObjectError, with: :handle_stale_object_error
      rescue_from ActionController::BadRequest, with: :handle_bad_request
      rescue_from ActionController::ParameterMissing, with: :handle_bad_request
      rescue_from ActionController::UnpermittedParameters, with: :handle_bad_request
      rescue_from ::Redis::ConnectionError, with: :handle_redis_connection_error
      alias_method :handle_bad_request, :handle_error
      alias_method :handle_record_not_found, :handle_error
    end
  end
end
