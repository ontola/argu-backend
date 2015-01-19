class Portal::PortalController < Portal::PortalBaseController
  def home
    authorize :portal, :home?
    @forums = Forum.order(memberships_count: :desc).all
    @pages = Page.all
  end

  def settings
    authorize :portal, :home?
    @settings = Setting.all
  end


  # This routes from portal/settings instead of /portal/settings/:value b/c of jeditable's crappy implementation..
  def set_setting
    authorize :portal, :home?

    if Setting.set(params[:key], params[:value])
      respond_to do |format|
        format.js { render text: params[:value] }
      end
    else
      respond_to do |format|
        format.js { head status: 400 }
      end
    end
  end

end