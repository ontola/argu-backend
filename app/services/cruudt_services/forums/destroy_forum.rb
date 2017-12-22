# frozen_string_literal: true

class DestroyForum < DestroyService
  private

  def confirmation_string
    I18n.t('forums.settings.advanced.delete.confirm.string')
  end
end
