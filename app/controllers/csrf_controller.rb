# frozen_string_literal: true

class CsrfController < ApplicationController
  def show
    skip_verify_policy_authorized true
    render json: {
      token: form_authenticity_token
    }
  end

  private

  def allowed_scopes
    %i[service]
  end
end
