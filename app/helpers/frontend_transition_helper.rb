# frozen_string_literal: true

# Contains methods which aid in the transition to the new front-end.
# This module should be removed when it is completely independent.
module FrontendTransitionHelper
  def false_unless_iframe
    'false' unless iframe?
  end

  def iframe_csrf_token
    request.headers['X-Iframe-Csrf-Token']
  end

  def iframe?
    params[:iframe] == 'true'
  end
end
