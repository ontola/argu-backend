module OrganisationsHelper
  def public_form_member_label(value)
    t("organisations.public_form.#{value}")
  end

  def application_form_member_label(value)
    t("organisations.application_form.#{value}")
  end

  def scope_member_label(value)
    t("organisations.scope.#{value}")
  end
end
