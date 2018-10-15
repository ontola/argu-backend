# frozen_string_literal: true

module Argu
  module Controller
    module ErrorHandling
      def error_response_html(e, view: nil, opts: {})
        @quote = (Setting.get(:quotes) || '').split(';').sample
        view ||= "status/#{error_status(e)}"

        render view, {status: error_status(e)}.merge(opts)
      end

      def handle_forbidden_html(e)
        @_not_authorized_caught = true
        flash[:alert] = e.message
        error_response_html(e, opts: {locals: {resource: user_with_r(request.original_url)}})
      end

      def handle_unauthorized_js(e)
        @_not_a_user_caught = true
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

      def handle_unauthorized_html(e)
        @_not_a_user_caught = true
        redirect_to new_user_session_path(r: e.r), alert: e.message
      end
    end
  end
end
