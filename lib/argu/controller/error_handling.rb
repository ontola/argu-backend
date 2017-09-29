# frozen_string_literal: true

module Argu
  # The generic Argu error handling code. Currently a mess from different error
  # classes with inconsistent attributes.
  module ErrorHandling
    extend ActiveSupport::Concern

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

    private

    def error_id(e)
      Argu::ERROR_TYPES[e.class].try(:[], :id) || 'BAD_REQUEST'
    end

    def error_mode(exception)
      @_error_mode = true
      Rails.logger.error exception
      @_uc = nil
    end

    def error_response_html(e, view: nil, opts: {})
      @quote = (Setting.get(:quotes) || '').split(';').sample
      view ||= "status/#{error_status(e)}"
      render view, {status: error_status(e)}.merge(opts)
    end

    def error_status(e)
      Argu::ERROR_TYPES[e.class].try(:[], :status) || 400
    end

    def handle_error(e)
      error_mode(e)
      respond_to do |format|
        format.html { error_response_html(e) }
        format.js { render status: error_status(e), json: json_error_hash(e) }
        format.json { render json_error(error_status(e), json_error_hash(e)) }
        format.json_api { render json_api_error(error_status(e), json_error_hash(e)) }
      end
    end

    def handle_bad_credentials(e)
      return handle_error(e) unless [:html, nil].include?(request.format.symbol)
      respond_to do |format|
        format.html { redirect_to new_user_session_path(r: e.r, show_error: true) }
      end
    end

    def handle_not_authorized_error(e)
      @_not_authorized_caught = true
      return handle_error(e) unless [:html, nil].include?(request.format.symbol)
      error_mode(e)
      respond_to do |format|
        format.html do
          flash[:alert] = e.message
          error_response_html(e, opts: {locals: {resource: user_with_r(request.original_url)}})
        end
      end
    end

    def handle_not_a_user_error(e)
      @_not_a_user_caught = true
      return handle_error(e) unless [:html, :js, nil].include?(request.format.symbol)
      error_mode(e)
      respond_to do |format|
        format.js do
          @resource = user_with_r(e.r)
          view_opts = {
            layout: false,
            locals: {
              resource: @resource,
              resource_name: :user,
              devise_mapping: Devise.mappings[:user],
              r: e.r
            }
          }
          error_response_html(e, view: 'devise/sessions/new', opts: view_opts)
        end
        format.html do
          if iframe?
            error_response_html(e, opts: {resource: user_with_r(request.original_url)})
          else
            redirect_to new_user_session_path(r: e.r), alert: e.message
          end
        end
      end
    end

    def handle_record_not_unique(e)
      return handle_error(e) unless [:html, nil].include?(request.format.symbol)
      error_mode(e)
      respond_to do |format|
        format.html do
          flash[:warning] = t(:twice_warning)
          redirect_back(fallback_location: root_path)
        end
      end
    end

    def handle_stale_object_error
      return handle_error(e) unless [:html, nil].include?(request.format.symbol)
      error_mode(e)
      respond_to do |format|
        format.html do
          correct_stale_record_version
          stale_record_recovery_action
        end
      end
    end

    def handle_redis_connection_error(exception)
      Redis.rescue_redis_connection_error(exception)
      raise '500'
    end

    def json_error_hash(error)
      {code: error_id(error), message: error.message}
    end

    # @param [Integer] status HTTP response code
    # @param [Array<Hash, String>] errors A list of errors
    # @return [Hash] Error hash to use in a render method
    def json_error(status, errors = nil)
      errors = json_api_formatted_errors(errors, Rack::Utils::HTTP_STATUS_CODES[status])
      {
        json: {
          code: errors&.first.try(:[], :code),
          message: errors&.first.try(:[], :message),
          notifications: errors.map { |error| {type: :error, message: error[:message]} }
        },
        status: status
      }
    end

    def respond_with(*resources, &_block)
      if [:html, nil].include?(request.format.symbol) || resources.all? { |r| r.respond_to?(:valid?) ? r.valid? : true }
        return super
      end
      respond_to do |format|
        format.json { respond_with_422(resources.first, :json) }
        format.json_api { respond_with_422(resources.first, :json_api) }
      end
    end

    def stale_record_recovery_action
      flash.now[:error] = 'Another user has made a change to that record since you accessed the edit form.'
      render :edit, status: :conflict
    end

    def user_with_r(r)
      User.new(r: r, shortname: Shortname.new)
    end
  end
end
