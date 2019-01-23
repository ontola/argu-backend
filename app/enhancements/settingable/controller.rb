# frozen_string_literal: true

module Settingable
  module Controller
    extend ActiveSupport::Concern

    included do
      active_response :settings
    end

    private

    def edit_success
      if %i[html js].include?(active_response_type)
        return respond_with_redirect location: settings_iri(authenticated_resource).to_s
      end
      respond_with_form(default_form_options(:edit))
    end

    def edit_view
      return default_form_view(:edit) unless %i[html js].include?(active_response_type)
      form_view_for(:settings)
    end

    def edit_view_locals
      return default_form_view_locals(:edit) unless %i[html js].include?(active_response_type)
      form_view_locals_for(:settings)
    end

    def settings_success
      return settings_success_html if %i[html js].include?(active_response_type)
      respond_with_resource(
        resource: authenticated_resource!.menu(user_context, :settings),
        include: [menu_sequence: [members: [:image, menu_sequence: [members: [:image]]]]]
      )
    end

    def settings_success_html
      respond_with_form(default_form_options(:settings))
    end

    def settings_view_locals
      {
        tab: tab!,
        active: tab!,
        resource: authenticated_resource
      }
    end

    def tab
      @tab ||= params[:tab] || params[model_name].try(:[], :tab) || policy(authenticated_resource).default_tab
    end

    def tab!
      @verified_tab ||= policy(authenticated_resource).verify_tab(tab)
    end
  end
end
