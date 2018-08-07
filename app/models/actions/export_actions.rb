# frozen_string_literal: true

module Actions
  class ExportActions < Base
    def create_description
      I18n.t('exports.create_helper')
    end
  end
end
