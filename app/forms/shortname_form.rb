# frozen_string_literal: true

class ShortnameForm < ApplicationForm
  field :shortname
  field :destination,
        description: lambda {
          I18n.t('shortnames.form.destination.description', iri_prefix: ActsAsTenant.current_tenant.iri_prefix)
        }
end
