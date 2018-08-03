# frozen_string_literal: true

class BetaController < ApplicationController
  def show
    cookies[:beta] = true
    redirect_to redirect_from_param || root_path
  end

  private

  def redirect_from_param
    return unless params[:r].present? && argu_iri_or_relative?(params[:r])
    params[:r].starts_with?('/') ? params[:r] : "/#{params[:r]}"
  end
end
