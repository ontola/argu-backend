# frozen_string_literal: true

class TermsController < ApplicationController
  active_response :new, :create

  private

  def create_execute
    current_user.update(accept_terms: true)
    current_user.send_reset_password_token_email if current_user.encrypted_password.blank?
  end

  def create_success
    head 200
  end

  def current_resource
    @current_resource ||= Term.new
  end
end
