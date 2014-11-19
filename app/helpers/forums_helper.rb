module ForumsHelper
  def public_form_member_label(value)
    t("forums.public_form.#{value}")
  end

  def application_form_member_label(value)
    t("forums.application_form.#{value}")
  end

  def scope_member_label(value)
    t("forums.scope.#{value}")
  end
end
