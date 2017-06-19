# frozen_string_literal: true

module CommentsHelper
  include DropdownHelper

  def comment_form_label(comment)
    comment.persisted? ? t('save') : t('reply')
  end
end
