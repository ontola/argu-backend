# frozen_string_literal: true

class DocumentsController < SimpleText::DocumentsController
  include Argu::Controller::Authorization

  after_action :make_scoped, only: :index
  layout :set_layout
  active_response :show

  private

  def current_resource
    @document = Document.find_by!(name: params[:name])
  end

  def make_scoped
    @documents = policy_scope(@documents)
  end
end
