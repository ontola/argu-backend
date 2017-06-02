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

    def handle_error(e)
      err_id = 'BAD_REQUEST'
      status = 400
      html, js = false
      user = User.new(r: request.original_url, shortname: Shortname.new) if @resource.class != User

      respond_to do |format|
        case e
        when Argu::NotAuthorizedError
          @_not_authorized_caught = true
          err_id = 'NOT_AUTHORIZED'
          status = 403
          format.js { render status: status, json: json_error_hash(err_id, e) }
          format.html do
            flash[:alert] = e.message
            render 'status/403',
                   status: 403,
                   locals: {resource: user, message: e.message}
          end
          html, js = true
        when Argu::NotAUserError
          @_not_a_user_caught = true
          err_id = 'NOT_A_USER'
          status = 401
          format.js do
            @resource = User.new(r: e.r, shortname: Shortname.new) if @resource.class != User
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
            if params[:iframe] == 'true'
              render "status/403", status: status, locals: {resource: user, message: e.message}
            else
              redirect_to new_user_session_path(r: e.r), alert: e.message
            end
          end
          html, js = true
        when ActiveRecord::RecordNotFound, ActionController::RoutingError
          err_id = 'NOT_FOUND'
          status = 404
        when ActiveRecord::RecordNotUnique
          err_id = 'NOT_UNIQUE'
          status = 304
          format.html do
            flash[:warning] = t(:twice_warning)
            redirect_back(fallback_location: root_path)
          end
          html = true
        when ActiveRecord::StaleObjectError
          err_id = 'STALE_OBJECT'
          status = 409
          format.html do
            correct_stale_record_version
            stale_record_recovery_action
          end
          html = true
        end

        unless html
          format.html do
            @quote = (Setting.get(:quotes) || '').split(';').sample
            render "status/#{status}", status: status, locals: {resource: user}
          end
        end
        js && format.js { head status }

        format.json { render status: status, json: json_error_hash(err_id, e) }
        format.json_api { render json_api_error(status, json_api_error_hash(err_id, e)) }
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
  end
end
