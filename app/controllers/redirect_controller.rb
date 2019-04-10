# frozen_string_literal: true

class RedirectController < ApplicationController
  def show
    ActsAsTenant.without_tenant do
      redirect_to(resource_by_shortname || resource_from_params)
    end
  end

  private

  def resource_from_params
    resource_from_opts(nil, params)
  end

  def resource_by_shortname
    params[:shortname] && Edge.find_via_shortname!(params[:shortname])
  end
end
