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
      rescue_from ActiveRecord::StaleObjectError, with: :handle_stale_object_error
      rescue_from ActionController::BadRequest, with: :handle_bad_request
      rescue_from ActionController::ParameterMissing, with: :handle_bad_request
      rescue_from ActionController::RoutingError, with: :handle_route_not_found
      rescue_from ActionController::UnpermittedParameters, with: :handle_bad_request
      rescue_from ::Redis::ConnectionError, with: :handle_redis_connection_error
      alias_method :handle_bad_request, :handle_error
      alias_method :handle_record_not_found, :handle_error
    end

    private

    def error_id(e)
      Argu::ERROR_TYPES[e.class].try(:[], :id) || 'BAD_REQUEST'
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
      respond_to do |format|
        format.html { error_response_html(e) }
        format.js { render status: error_status(e), json: json_error_hash(error_id(e), e) }
        format.json { render status: error_status(e), json: json_error_hash(error_id(e), e) }
        format.json_api { render json_api_error(error_status(e), json_api_error_hash(error_id(e), e)) }
      end
    end

    def handle_not_authorized_error(e)
      @_not_authorized_caught = true
      return handle_error(e) unless request.format.html?
      respond_to do |format|
        format.html do
          flash[:alert] = e.message
          error_response_html(e, opts: {locals: {resource: user_with_r(request.original_url)}})
        end
      end
    end

    def handle_not_a_user_error(e)
      @_not_a_user_caught = true
      return handle_error(e) unless %i(html js).include?(request.format.symbol)
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
      return handle_error(e) unless request.format.html?
      respond_to do |format|
        format.html do
          flash[:warning] = t(:twice_warning)
          redirect_back(fallback_location: root_path)
        end
      end
    end

    def handle_stale_object_error
      return handle_error(e) unless request.format.html?
      respond_to do |format|
        format.html do
          correct_stale_record_version
          stale_record_recovery_action
        end
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
