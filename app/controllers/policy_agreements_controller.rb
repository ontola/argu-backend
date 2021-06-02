# frozen_string_literal: true

class PolicyAgreementsController < ApplicationController
  active_response :create

  private

  def create_execute
    current_user.update(accept_terms: true)
    current_user.send_reset_password_token_email if current_user.encrypted_password.blank?
    true
  end

  def create_success
    head 200
  end
end
