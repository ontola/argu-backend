# frozen_string_literal: true

module Actions
  class Item < LinkedRails::Actions::Item
    def error
      return super unless action_status == NS::ONTOLA[:DisabledActionStatus]

      resource_policy.message || super
    end

    def iri(opts = {})
      return @iri if @iri && opts.empty?

      iri ||= ActsAsTenant.with_tenant(resource.try(:root) || ActsAsTenant.current_tenant) { super }
      @iri = iri if opts.empty?
      iri
    end
  end
end
