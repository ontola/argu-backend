# frozen_string_literal: true

class TermsController < ApplicationController
  active_response :new, :create

  private

  def create_execute
    current_user.accept_terms!
  end

  def create_success
    head 200
  end

  def current_resource
    @current_resource ||= Term.new
  end
end
