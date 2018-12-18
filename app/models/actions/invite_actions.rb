# frozen_string_literal: true

module Actions
  class InviteActions < Base
    private

    def association_class
      Invite
    end

    def create_description
      I18n.t('tokens.discussion.description')
    end

    def create_on_collection?
      false
    end

    def create_policy
      :create?
    end

    def create_url(_resource)
      RDF::DynamicURI(expand_uri_template(:tokens_iri, with_hostname: true))
    end

    def new_label
      I18n.t('tokens.discussion.title')
    end
  end
end
