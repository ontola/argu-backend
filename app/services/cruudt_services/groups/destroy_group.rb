# frozen_string_literal: true

class DestroyGroup < DestroyService
  private

  def confirmation_string
    I18n.t('groups.delete.cancel_string')
  end
end
