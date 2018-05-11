# frozen_string_literal: true

# Contains methods which aid in the transition to the new front-end.
# This module should be removed when it is completely independent.
module FrontendTransitionHelper
  def aod_request?
    new_fe_request? && doorkeeper_token.application_id.zero?
  end

  def false_unless_iframe
    'false' unless iframe?
  end

  def iframe_csrf_token
    request.headers['X-Iframe-Csrf-Token']
  end

  def iframe?
    params[:iframe] == 'true'
  end

  def new_fe_request?
    request.headers['X-Argu-Back']&.to_s == 'true'
  end

  def request_session_id
    @_session_id ||= new_fe_request? ? doorkeeper_token.resource_owner_id : request.session.id
  end

  def session
    new_fe_request? ? doorkeeper_token : super
  end

  def session_id
    @_session_id ||= new_fe_request? ? doorkeeper_token.resource_owner_id : session.id
  end
end
