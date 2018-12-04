# frozen_string_literal: true

class Portal::PortalController < Portal::PortalBaseController
  skip_before_action :authorize_action, only: :home
  skip_after_action :verify_authorized, only: :home
  prepend_view_path 'app/views/portal/portal'

  def home # rubocop:disable Metrics/AbcSize
    authorize :portal, :home?
    @forums = Forum.order(display_name: :asc).page(params[:forums_page]).per(500)
    @pages = Page
               .includes(:profile, :children)
               .order('profiles.name ASC')
               .page(params[:pages_page])
               .per(500)
    @settings = Setting.all

    render locals: {
      tab: tab,
      active: tab
    }
  end

  # This routes from portal/settings instead of /portal/settings/:value b/c of jeditable's crappy implementation..
  def setting!
    authorize :portal, :home?

    if Setting.set(params[:key], params[:value])
      respond_to do |format|
        format.js { render }
      end
    else
      respond_to do |format|
        format.js { head status: 400 }
      end
    end
  end

  private

  def tab
    policy(:Portal).verify_tab(params[:tab])
  end
end
