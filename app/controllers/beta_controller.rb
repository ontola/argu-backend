# frozen_string_literal: true

class BetaController < ApplicationController
  def show
    cookies[:beta] = true
    redirect_to "https://app.#{Rails.application.config.host_name}#{redirect_from_param}"
  end

  private

  def redirect_from_param
    return unless params[:r].present? && argu_iri_or_relative?(params[:r])
    params[:r].starts_with?('/') ? params[:r] : "/#{params[:r]}"
  end
end
