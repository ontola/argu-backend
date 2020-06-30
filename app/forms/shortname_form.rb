# frozen_string_literal: true

class ShortnameForm < ApplicationForm
  field :shortname
  field :destination,
        description: lambda {
          I18n.t('formtastic.hints.shortname.destination', iri_prefix: ActsAsTenant.current_tenant.iri_prefix)
        }
  field :unscoped
end
