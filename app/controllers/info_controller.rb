class InfoController < ApplicationController
  def show
    begin
      setting = Setting.get(params[:id])
      raise ActiveRecord::RecordNotFound if setting.blank?
      @document = JSON.parse setting
      raise ActiveRecord::RecordNotFound if @document['sections'].blank?
    rescue JSON::ParserError
      raise ActiveRecord::RecordNotFound
    end
    # TODO: Create InfoPolicy and validate documents accordingly. Don't use settings.
    authorize :static_page, :about?
  end
end
