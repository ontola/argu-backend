# frozen_string_literal: true

class TokensController < ApplicationController
  active_response :new

  private

  def ld_action(opts)
    opts[:resource].action(:create, user_context)
  end

  def new_resource_params
    params.permit(:r)
  end

  def permit_params
    params.require(:session).permit(:r, :email)
  end
end
