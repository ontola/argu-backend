# frozen_string_literal: true

class RedirectController < ApplicationController
  def show
    ActsAsTenant.without_tenant do
      redirect_to(resource_by_shortname || requested_resource || raise(ActiveRecord::RecordNotFound))
    end
  end

  private

  def requested_resource
    LinkedRails.resource_from_opts(params)
  end

  def resource_by_shortname
    params[:shortname] && Edge.find_via_shortname!(params[:shortname])
  end
end
