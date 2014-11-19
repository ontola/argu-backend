class Portal::PortalController < Portal::PortalBaseController
  def home
    authorize :portal, :home?
    @forums = Forum.order(memberships_count: :desc).all
    @pages = Page.all
  end

end