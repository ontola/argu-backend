# frozen_string_literal: true

class AccessTokensController < ApplicationController
  active_response :new

  private

  def ld_action(opts)
    opts[:resource].action(:create, user_context)
  end

  def new_resource_params
    params.permit(:redirect_url)
  end

  def permit_params
    params.require(:session).permit(:redirect_url, :email)
  end
end
