# frozen_string_literal: true

class ContainerNodeForm < ApplicationForm
  class << self
    def grants_group
      group :grants,
            description: -> { I18n.t('forms.grants.description') },
            label: -> { I18n.t('forms.grants.label') } do
        field :grants, **grant_options
      end
    end

    def grant_options
      {
        input_field: GrantsInput,
        form: Grants::EdgeForm,
        label: '',
        max_count: 999
      }
    end

    def url_options
      {
        start_adornment: -> { "#{ActsAsTenant.current_tenant.iri}/" }
      }
    end
  end
end
