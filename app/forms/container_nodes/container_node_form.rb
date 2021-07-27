# frozen_string_literal: true

class ContainerNodeForm < ApplicationForm
  class << self
    def grant_options
      {
        description: lambda do
          grants_list =
            ActsAsTenant.current_tenant.grants.joins(:grant_set).where("grant_sets.title != 'staff'").map do |grant|
              "**#{grant.group.display_name}**: #{I18n.t("roles.types.#{grant.grant_set.title}")}"
            end.join("\n")
          "#{I18n.t('grants.form.description')}\n#{grants_list}"
        end,
        form: Grants::EdgeForm
      }
    end

    def url_options
      {
        description: lambda do
          I18n.t('shortnames.form.destination.description', iri_prefix: ActsAsTenant.current_tenant.iri_prefix)
        end
      }
    end
  end
end
