# frozen_string_literal: true

# Contains methods which aid in the transition to the new front-end.
# This module should be removed when it is completely independent.
module FrontendTransitionHelper
  # Is the request being made by the argu front end?
  def afe_request?
    @_new_fe_request ||= doorkeeper_token&.scopes&.include?('afe')
  end

  def api_request?
    return if try(:cookies).try(:[], Rails.configuration.cookie_name).present?

    request.headers['Authorization'].present? && !request.format.html?
  end

  def session_id
    @_session_id ||= afe_request? ? doorkeeper_token.resource_owner_id : session.id
  end

  def vnext_request?
    afe_request? || api_request?
  end
end
