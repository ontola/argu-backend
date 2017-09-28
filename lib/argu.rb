# frozen_string_literal: true

require 'argu/controller'
require 'argu/ruled_it'
require 'argu/not_authorized_error'
require 'argu/not_a_user_error'
require 'argu/unknown_email_error'
require 'argu/unknown_username_error'
require 'argu/wrong_password_error'

require 'react-rails/lib/server_rendering/webpack_manifest_container'

module Argu
  ERROR_TYPES = {
    Argu::NotAuthorizedError => {
      id: 'NOT_AUTHORIZED',
      status: 403
    },
    Argu::NotAUserError => {
      id: 'NOT_A_USER',
      status: 401
    },
    Argu::UnknownEmailError => {
      id: 'UNKNOWN_EMAIL',
      status: 422
    },
    Argu::UnknownUsernameError => {
      id: 'UNKNOWN_USERNAME',
      status: 422
    },
    Argu::WrongPasswordError => {
      id: 'WRONG_PASSWORD',
      status: 422
    },
    ActiveRecord::RecordNotFound => {
      id: 'NOT_FOUND',
      status: 404
    },
    ActionController::RoutingError => {
      id: 'NOT_FOUND',
      status: 404
    },
    ActiveRecord::RecordNotUnique => {
      id: 'NOT_UNIQUE',
      status: 304
    },
    ActiveRecord::StaleObjectError => {
      id: 'STALE_OBJECT',
      status: 409
    }
  }.freeze
end
