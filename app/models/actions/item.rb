# frozen_string_literal: true

module Actions
  class Item < LinkedRails::Actions::Item
    # Return options used by DropdownHelper#dropdown_options
    def dropdown_options(opts)
      (link_opts || {}).merge(fa: image).merge(opts)
    end

    # @todo this overwrite might not be needed when the old frontend is ditched
    def iri(opts = {})
      return super if ActsAsTenant.current_tenant.present?
      return @iri if @iri && opts.blank?
      iri = ActsAsTenant.with_tenant(resource.try(:root)) { super }
      @iri = iri if opts.blank?
      iri
    end
  end
end
