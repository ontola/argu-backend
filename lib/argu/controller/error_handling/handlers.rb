# frozen_string_literal: true

module Argu
  # The generic Argu error handling code. Currently a mess from different error
  # classes with inconsistent attributes.
  module ErrorHandling
    module Handlers
      def error_response_html(e, view: nil, opts: {})
        @quote = (Setting.get(:quotes) || '').split(';').sample
        view ||= "status/#{error_status(e)}"
        render view, {status: error_status(e)}.merge(opts)
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

      def handle_oauth_error(e)
        case e.response.status
        when 401
          handle_unauthorized_error
        when 403
          handle_forbidden_error
        else
          handle_general_oauth_error(e)
        end
      end

      def handle_general_oauth_error(e)
        Bugsnag.notify(e)
        respond_to do |format|
          format.html { error_response_html(e) }
          format.json { render status: 500 }
          format.json_api { render json_api_error(500, e.response.body) }
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

      def stale_record_recovery_action
        flash.now[:error] = 'Another user has made a change to that record since you accessed the edit form.'
        render :edit, status: :conflict
      end
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
  end
end
