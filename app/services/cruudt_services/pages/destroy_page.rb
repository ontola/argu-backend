# frozen_string_literal: true

class DestroyPage < DestroyService
  private

  def confirmation_string
    I18n.t('pages.settings.advanced.delete.confirm.string')
  end
end
