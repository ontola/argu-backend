# frozen_string_literal: true

class DocumentsController < ApplicationController
  include Argu::Controller::Authorization
  active_response :show

  private

  def current_resource
    @current_resource = Document.find_by(name: params[:name])
  end
end
