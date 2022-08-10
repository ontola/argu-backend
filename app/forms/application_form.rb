# frozen_string_literal: true

class ApplicationForm < LinkedRails::Form
  extend URITemplateHelper

  class << self
    def form_options_iri(attr, klass = nil)
      -> { LinkedRails.iri(path: "/enums/#{(klass || model_class).to_s.tableize}/#{attr}") }
    end

    private

    def actor_selector(attr = :creator)
      field attr,
            datatype: NS.xsd.string,
            max_count: 1,
            sh_in: -> { actors_iri }
    end

    def actor_step
      resource :creator, url: -> { current_actor_iri }
    end

    def mark_as_important_label
      I18n.t('publications.follow_type.helper')
    end

    def term_field(key, url, **opts)
      field key, **{
        datatype: NS.xsd.string,
        sh_in: -> { Vocabulary.terms_iri(url, **opts[:sh_in_opts] || {}) }
      }.merge(**opts.except(:sh_in_opts))
    end

    def visibility_text
      resource :visibility_text, path: NS.argu[:grantedGroups]
    end
  end
end
