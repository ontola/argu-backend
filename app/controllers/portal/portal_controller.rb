class Portal::PortalController < Portal::PortalBaseController
  def home
    authorize :portal, :home?
    @organisations = Organisation.order(memberships_count: :desc).all
  end

end