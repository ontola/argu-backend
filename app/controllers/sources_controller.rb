# frozen_string_literal: true
class SourcesController < AuthorizedController
  def settings
    prepend_view_path 'app/views/sources'

    render locals: {
      tab: tab,
      active: tab,
      resource: resource_by_id
    }
  end

  def update
    update_service.on(:update_source_successful) do |source|
      redirect_to settings_page_source_path(source.page, source, tab: tab),
                  notice: t('type_save_success', type: t('sources.type'))
    end
    update_service.on(:update_source_failed) do
      render 'settings',
             locals: {
               tab: tab,
               active: tab
             }
    end
    update_service.commit
  end

  private

  def resource_by_id
    @_resource_by_id ||= Source.find_by!(shortname: params[:id])
  end

  def tab
    policy(authenticated_resource).verify_tab(params[:tab] || params[:source].try(:[], :tab))
  end
end
