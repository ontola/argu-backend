# frozen_string_literal: true

class InfoController < ApplicationController
  # TODO: Create InfoPolicy and validate documents accordingly.
  def show
    setting = Setting.get(params[:id])
    raise ActiveRecord::RecordNotFound if setting.blank?
    @document = JSON.parse setting
    raise ActiveRecord::RecordNotFound if @document['sections'].blank?
  rescue JSON::ParserError
    raise ActiveRecord::RecordNotFound
  end
end
