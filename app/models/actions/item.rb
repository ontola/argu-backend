# frozen_string_literal: true

module Actions
  class Item < LinkedRails::Actions::Item
    # Return options used by DropdownHelper#dropdown_options
    def dropdown_options(opts)
      (link_opts || {}).merge(fa: image).merge(opts)
    end

    def error
      return super unless action_status == NS::ONTOLA[:DisabledActionStatus]

      resource_policy.message || super
    end

    def iri(opts = {})
      ActsAsTenant.with_tenant(resource.try(:root) || ActsAsTenant.current_tenant) { super }
    end
  end
end
