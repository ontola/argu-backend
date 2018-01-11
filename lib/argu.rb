# frozen_string_literal: true

require 'argu/controller'
require 'argu/ruled_it'
require 'argu/errors/not_authorized'
require 'argu/errors/not_a_user'
require 'argu/errors/unknown_email'
require 'argu/errors/unknown_username'
require 'argu/errors/wrong_password'

require 'react-rails/lib/server_rendering/webpack_manifest_container'

module Argu
  ERROR_TYPES = {
    Argu::Errors::NotAuthorized => {
      id: 'NOT_AUTHORIZED',
      status: 403
    },
    Argu::Errors::NotAUser => {
      id: 'NOT_A_USER',
      status: 401
    },
    Argu::Errors::UnknownEmail => {
      id: 'UNKNOWN_EMAIL',
      status: 422
    },
    Argu::Errors::UnknownUsername => {
      id: 'UNKNOWN_USERNAME',
      status: 422
    },
    Argu::Errors::WrongPassword => {
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
