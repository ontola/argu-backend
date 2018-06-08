# frozen_string_literal: true

module Createable
  module Action
    extend ActiveSupport::Concern

    included do
      include Pundit

      define_action(
        :new,
        result: -> { association_class },
        type: -> { [NS::ARGU["New#{association_class}"], NS::SCHEMA[:NewAction]] },
        policy: :create_child?,
        label: -> { new_label },
        image: -> { new_image },
        url: -> { new_url(resource) },
        http_method: :get,
        collection: true
      )

      define_action(
        :create,
        result: -> { association_class },
        type: -> { [NS::ARGU["Create#{association_class}"], NS::ARGU[:CreateAction]] },
        policy: :create_child?,
        label: -> { new_label },
        image: -> { new_image },
        url: -> { create_url(resource) },
        http_method: :post,
        collection: true
      )
    end

    private

    def association
      @association ||= association_class.to_s.tableize
    end

    def association_class
      resource.association_class
    end

    def new_url(resource)
      col_iri = resource.iri(only_path: true)
      query = col_iri.query
      col_iri.query = nil
      iri = RDF::URI(expand_uri_template('new_iri', collection_iri: col_iri))
      iri.query = query if query.present?
      iri
    end

    def new_image
      'fa-plus'
    end

    def new_label
      I18n.t("#{association}.type_new")
    end

    def resource_path_iri
      return super unless paged_resource?(resource)

      self_without_page = resource.parent_view_iri
      self_without_page.host = nil
      self_without_page.scheme = nil
      self_without_page
    end
  end
end
