class DocumentsController < SimpleText::DocumentsController
  after_action :verify_authorized, :except => :index
  after_action :verify_policy_scoped, :only => :index
  after_action :make_authorized, except: :index
  after_action :make_scoped, only: :index

  def make_authorized
    authorize @document
  end

  def make_scoped
    policy_scope @documents
  end
end