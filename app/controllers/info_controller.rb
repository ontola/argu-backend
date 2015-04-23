class InfoController < ApplicationController

  def show
    begin
      setting = Setting.get(params[:id])
      if setting.blank?
        raise ActiveRecord::RecordNotFound
      end
      @document = JSON.parse setting
      if @document['sections'].blank?
        raise ActiveRecord::RecordNotFound
      end
    rescue JSON::ParserError
      raise ActiveRecord::RecordNotFound
    end
    # TODO Create InfoPolicy and validate documents accordingly. Don't use settings.
    authorize :static_pages, :about?
  end
end