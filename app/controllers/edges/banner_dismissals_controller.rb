# frozen_string_literal: true

class BannerDismissalsController < EdgeableController
  private

  def active_response_success_message; end

  def allow_empty_params?
    true
  end
end
