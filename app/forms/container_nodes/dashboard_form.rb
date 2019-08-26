# frozen_string_literal: true

class DashboardForm < ApplicationForm
  fields [
    :display_name,
    :bio,
    :bio_long,
    :locale,
    :url,
    :default_cover_photo,
    grants: {
      description: lambda do
        grants_list =
          target.root.grants.joins(:grant_set).where("grant_sets.title != 'staff'").map do |grant|
            "#{grant.group.display_name}: #{I18n.t("roles.types.#{grant.grant_set.title}")}"
          end.join("\n")
        "#{I18n.t('grants.form.description')}\n#{grants_list}"
      end
    }
  ]
end