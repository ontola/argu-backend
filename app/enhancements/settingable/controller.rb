# frozen_string_literal: true

module Settingable
  module Controller
    extend ActiveSupport::Concern

    included do
      active_response :settings
    end

    private

    def edit_success
      respond_with_form(default_form_options(:edit))
    end

    def resource_settings_iri
      settings_iri(authenticated_resource, tab: tab)
    end

    def settings_success
      return respond_with_redirect(location: resource_settings_iri) if tab_param

      respond_with_resource(
        resource: authenticated_resource!.menu(:settings, user_context),
        include: [menu_sequence: [members: [:image, menu_sequence: [members: [:image]]]]]
      )
    end

    def tab_param
      params[:tab] || params[model_name].try(:[], :tab)
    end

    def tab
      @tab ||= tab_param || policy(authenticated_resource).default_tab
    end

    def tab!
      # rubocop:disable Naming/MemoizedInstanceVariableName
      @verified_tab ||= policy(authenticated_resource).verify_tab(tab)
      # rubocop:enable Naming/MemoizedInstanceVariableName
    end
  end
end
