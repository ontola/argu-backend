# frozen_string_literal: true
class Portal::PortalController < Portal::PortalBaseController
  prepend_view_path 'app/views/portal/portal'

  def home
    authorize :portal, :home?
    @forums = Forum.order(name: :asc).page(params[:pages_page]).per(100)
    @pages = Page.includes(:profile).order('profiles.name ASC').page(params[:pages_page]).per(100)
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
        format.js { render text: escape_javascript(params[:value]) }
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
