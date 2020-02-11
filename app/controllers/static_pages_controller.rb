# frozen_string_literal: true

class StaticPagesController < AuthorizedController
  skip_before_action :authorize_action, only: :not_found
  skip_before_action :check_if_registered
  skip_after_action :verify_authorized, only: :not_found

  def home
    active_response_block do
      respond_with_redirect location: current_user.is_staff? ? feeds_iri(nil) : preferred_forum.iri
    end
  end

  def not_found
    handle_error(ActionController::RoutingError.new('Route not found'))
  end

  private

  def authorize_action
    authorize :static_page
  end
end
