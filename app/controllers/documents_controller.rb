class DocumentsController < SimpleText::DocumentsController
  after_action :verify_authorized, :except => :index
  after_action :make_authorize, except: :index

  def make_authorize
    authorize @document
  end

  def simple_text_controller?
    true
  end

end