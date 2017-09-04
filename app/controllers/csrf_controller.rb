# frozen_string_literal: true

class CsrfController < ApplicationController
  skip_before_action :doorkeeper_authorize!
  before_action -> { doorkeeper_authorize! :service }

  def show
    skip_verify_policy_authorized true
    render json: {
      token: form_authenticity_token
    }
  end
end
