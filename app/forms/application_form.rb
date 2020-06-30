# frozen_string_literal: true

class ApplicationForm < LinkedRails::Form
  extend UriTemplateHelper

  class << self
    def form_iri
      RDF::DynamicURI(LinkedRails.iri(path: "/forms/#{to_s.sub('Form', '').tableize}"))
    end

    def form_options_iri(attr)
      -> { RDF::DynamicURI(LinkedRails.iri(path: "/enums/#{model_class.to_s.tableize}/#{attr}")) }
    end

    private

    def actor_selector(attr = :creator)
      field attr,
            datatype: NS::XSD[:string],
            max_count: 1,
            sh_in: -> { actors_iri }
    end

    def actor_step
      resource :creator, url: -> { current_actor_iri }
    end

    def mark_as_important_label
      I18n.t('publications.follow_type.helper')
    end

    def visibility_text
      resource :visibility_text, path: NS::ARGU[:grantedGroups]
    end
  end
end
