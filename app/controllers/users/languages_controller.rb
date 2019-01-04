# frozen_string_literal: true

module Users
  class LanguagesController < ApplicationController
    active_response :edit, :update

    private

    def active_response_action_name(_view)
      :language
    end

    def locale_param
      (params.permit(:locale)[:locale] || params.require(:user).require(:language)).to_sym
    end

    def new_oauth_token
      if current_user.guest?
        generate_guest_token(current_user.id, application: doorkeeper_token.application)
      else
        generate_user_token(current_user, application: doorkeeper_token.application)
      end
    end

    def requested_resource
      @requested_resource ||= current_user
    end

    def update_execute
      return false unless valid_locale?
      if current_user.guest?
        Argu::Redis.set("guest_user.#{current_user.id}.language", locale_param)
      else
        return false unless current_user.update(language: locale_param)
      end
      update_oauth_token(new_oauth_token.token)
    end

    def update_failure
      respond_with_redirect(location: request.headers['Referer'] || root_path, notice: t('errors.general'))
    end

    def update_success
      respond_with_redirect(location: request.headers['Referer'] || root_path)
    end

    def valid_locale?
      return true if I18n.available_locales.include?(locale_param)
      Bugsnag.notify(RuntimeError.new("Invalid locale #{locale_param}"))
      false
    end

    class << self
      def controller_class
        User
      end
    end
  end
end