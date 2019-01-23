# frozen_string_literal: true

# Additional helpers only for RSpec
module Argu
  module TestHelpers
    module IriHelpers
      include UriTemplateHelper

      def collection_iri(parent, type, opts = {})
        parent.instance_variable_set(:@iri, nil) if parent.instance_variable_get(:@iri)
        ActsAsTenant.with_tenant(opts.delete(:root) || ActsAsTenant.current_tenant || parent.try(:root)) do
          super
        end
      end

      def new_iri(parent, collection = nil, opts = {})
        parent.instance_variable_set(:@iri, nil) if parent.instance_variable_get(:@iri)
        ActsAsTenant.with_tenant(opts.delete(:root) || ActsAsTenant.current_tenant || parent.try(:root)) do
          super
        end
      end

      %i[edit delete trash untrash settings statistics feeds conversions invites export logs].each do |method|
        define_method "#{method}_iri" do |parent, opts = {}|
          parent.instance_variable_set(:@iri, nil) if parent.instance_variable_get(:@iri)
          ActsAsTenant.with_tenant(opts.delete(:root) || ActsAsTenant.current_tenant || parent.try(:root)) do
            super(parent, opts)
          end
        end
      end

      def resource_iri(resource, opts = {})
        resource.instance_variable_set(:@iri, nil) if resource.instance_variable_get(:@iri)
        ActsAsTenant.with_tenant(opts.delete(:root) || ActsAsTenant.current_tenant || resource.try(:root)) do
          resource.iri(opts)
        end
      end
    end
  end
end
