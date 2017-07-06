# frozen_string_literal: true
module Argu
  # The generic Argu error handling code. Currently a mess from different error
  # classes with inconsistent attributes.
  module ErrorHandling
    extend ActiveSupport::Concern

    included do
      rescue_from Argu::NotAUserError, with: :handle_not_a_user_error
      rescue_from Argu::NotAuthorizedError, with: :handle_not_authorized_error
      rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
      rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique
      rescue_from ActiveRecord::StaleObjectError, with: :rescue_stale
      rescue_from ActionController::BadRequest, with: :handle_bad_request
      rescue_from ActionController::ParameterMissing, with: :handle_bad_request
      rescue_from ActionController::RoutingError, with: :handle_route_not_found
      rescue_from ActionController::UnpermittedParameters, with: :handle_bad_request
      rescue_from ::Redis::ConnectionError, with: :handle_redis_connection_error
      alias_method :handle_not_a_user_error, :handle_error
      alias_method :handle_not_authorized_error, :handle_error
      alias_method :handle_record_not_found, :handle_error
      alias_method :handle_record_not_unique, :handle_error
      alias_method :rescue_stale, :handle_error
      alias_method :handle_bad_request, :handle_error
      alias_method :handle_route_not_found, :handle_error
    end

    private

    def error_id(e)
      Argu::ERROR_TYPES[e.class].try(:[], :id) || 'BAD_REQUEST'
    end

    def error_status(e)
      Argu::ERROR_TYPES[e.class].try(:[], :status) || 400
    end

    def handle_error(e)
      respond_to do |format|
        case e
        when Argu::NotAuthorizedError
          @_not_authorized_caught = true
          format.js { render status: error_status(e), json: json_error_hash(error_id(e), e) }
          format.html do
            flash[:alert] = e.message
            render 'status/403',
                   status: 403,
                   locals: {resource: user_with_r(request.original_url), message: e.message}
          end
        when Argu::NotAUserError
          @_not_a_user_caught = true
          format.js do
            @resource = user_with_r(e.r)
            render 'devise/sessions/new',
                   layout: false,
                   locals: {
                     resource: @resource,
                     resource_name: :user,
                     devise_mapping: Devise.mappings[:user],
                     r: e.r
                   }
          end
          format.html do
            if iframe?
              render 'status/403', status: error_status(e), locals: {resource: user_with_r(request.original_url)}
            else
              redirect_to new_user_session_path(r: e.r), alert: e.message
            end
          end
        when ActiveRecord::RecordNotUnique
          format.html do
            flash[:warning] = t(:twice_warning)
            redirect_back(fallback_location: root_path)
          end
        when ActiveRecord::StaleObjectError
          format.html do
            correct_stale_record_version
            stale_record_recovery_action
          end
        end

        format.html do
          @quote = (Setting.get(:quotes) || '').split(';').sample
          render "status/#{error_status(e)}", status: error_status(e)
        end
        format.js { head error_status(e) }
        format.json { render status: error_status(e), json: json_error_hash(error_id(e), e) }
        format.json_api { render json_api_error(error_status(e), json_api_error_hash(error_id(e), e)) }
      end
    end

    def json_error_hash(id, exception)
      error = {type: :error, error_id: id, message: exception.message}
      error.merge(notifications: [error])
    end

    def json_api_error_hash(id, exception)
      {code: id, message: exception.message}
    end

    def handle_redis_connection_error(exception)
      Redis.rescue_redis_connection_error(exception)
      raise '500'
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
