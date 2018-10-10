# frozen_string_literal: true

class TermsController < ApplicationController
  active_response :new, :create

  private

  def create_execute
    current_user.accept_terms!
    add_exec_action_header(response.headers, params[:referrer])
  end

  def create_success
    head 200
  end

  def current_resource
    Term.new(referrer: params[:referrer])
  end
end
