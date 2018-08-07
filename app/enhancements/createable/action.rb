# frozen_string_literal: true

module Createable
  module Action
    extend ActiveSupport::Concern

    included do
      include Pundit

      define_action(
        :create,
        result: -> { association_class },
        type: -> { [NS::ARGU["Create#{association_class}"], NS::SCHEMA[:CreateAction]] },
        policy: -> { create_policy },
        label: -> { new_label },
        image: -> { new_image },
        url: -> { create_url(resource) },
        http_method: :post,
        collection: -> { create_on_collection? },
        form: -> { "#{association_class}Form".safe_constantize },
        iri_template: :new_iri
      )
    end

    private

    def association
      @association ||= association_class.to_s.tableize
    end

    def association_class
      resource.association_class
    end

    def create_on_collection?
      true
    end

    def create_policy
      :create_child?
    end

    def create_url(resource)
      resource.iri
    end

    def new_image
      'fa-plus'
    end

    def new_label
      I18n.t("#{association}.type_new")
    end
  end
end
