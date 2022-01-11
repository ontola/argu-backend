# frozen_string_literal: true

class StaticPagesController < AuthorizedController
  include URITemplateHelper

  skip_after_action :verify_authorized, only: :not_found

  def not_found
    handle_error(ActionController::RoutingError.new('Route not found'))
  end
end
