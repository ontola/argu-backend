# frozen_string_literal: true

module Users
  class UnlocksController < Devise::UnlocksController
    active_response :new

    private

    def after_sending_unlock_instructions_path_for(_resource_name)
      afe_request? ? RDF::DynamicURI(path_with_hostname('/u/sign_in')).path : new_user_session_path
    end

    def create_execute
      self.resource = resource_class.send_unlock_instructions(resource_params)
      yield resource if block_given?
    end

    def default_form_view(action)
      action
    end

    def new_execute
      self.resource = resource_class.new
    end

    def resource_params
      params.fetch(resource_name, nil) ||
        params.fetch("#{resource_name.to_s.pluralize}/#{controller_name.singularize}", {})
    end
  end
end
