# frozen_string_literal: true

module ActionableHelper
  extend ActiveSupport::Concern

  included do
    def collection_create_url(col_name)
      RDF::URI(create_url(resource_collection(col_name)))
    end

    def create_url(resource)
      return resource.parent_view_iri if paged_resource?(resource)
      resource.iri
    end

    def paged_resource?(resource)
      resource.is_a?(Collection) && resource.pagination && resource.page.present?
    end

    def resource_collection(col_name)
      resource.send("#{col_name}_collection".to_sym, user_context: user_context)
    end
  end

  module ClassMethods
    def define_default_create_action(resource_name, image: 'fa-plus')
      define_action resource_name.to_sym

      action_name = "#{resource_name}_action".to_sym
      create_action = "create_#{resource_name}".to_sym
      entrypoint_name = "#{resource_name}_entrypoint".to_sym
      policy = "#{resource_name}?".to_sym

      define_method action_name do
        action_item(
          create_action,
          target: send(entrypoint_name),
          resource: resource_collection(resource_name),
          result: resource_name.to_s.classify.safe_constantize,
          type: [
            NS::ARGU[:CreateAction],
            NS::ARGU[create_action.to_s.camelize]
          ],
          policy: policy
        )
      end

      define_method entrypoint_name do
        entry_point_item(
          create_action,
          image: image,
          url: collection_create_url(resource_name),
          http_method: 'POST'
        )
      end
    end
  end
end
