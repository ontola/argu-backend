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
      RDF::DynamicURI(LinkedRails.iri(path: 'u/tokens/new'))
    else
      RDF::DynamicURI(LinkedRails.iri(path: 'u/new'))
    end
  end

  def ld_action(opts)
    opts[:resource].action(:create, user_context)
  end

  def new_resource_params
    params.permit(:r)
  end

  def permit_params
    params.require(:session).permit(:r, :email)
  end

  def r_param
    new_resource_params[:r] || permit_params[:r]
  end
end
