# frozen_string_literal: true

class SessionsController < ApplicationController
  active_response :new, :create

  private

  def active_response_success_message; end

  def create_execute
    true
  end

  def create_success_location
    if User.find_for_database_authentication(email: permit_params[:email])
      LinkedRails.iri(path: 'u/access_tokens/new')
    else
      LinkedRails.iri(path: 'u/new')
    end
  end

  def ld_action(opts)
    opts[:resource].action(:create, user_context)
  end

  def new_resource_params
    params.permit(:redirect_url)
  end

  def permit_params
    params.require(:session).permit(:redirect_url, :email)
  end

  def r_param
    new_resource_params[:redirect_url] || permit_params[:redirect_url]
  end
end
