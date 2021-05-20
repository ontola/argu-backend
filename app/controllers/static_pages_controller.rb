# frozen_string_literal: true

class StaticPagesController < AuthorizedController
  include UriTemplateHelper

  skip_before_action :authorize_action, only: :not_found
  skip_after_action :verify_authorized, only: :not_found

  def not_found
    handle_error(ActionController::RoutingError.new('Route not found'))
  end

  private

  def authorize_action
    authorize :static_page
  end
end
