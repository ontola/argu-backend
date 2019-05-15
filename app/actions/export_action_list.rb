# frozen_string_literal: true

class ExportActionList < ApplicationActionList
  def create_description
    I18n.t('exports.create_helper')
  end
end
