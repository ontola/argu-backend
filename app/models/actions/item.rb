# frozen_string_literal: true

module Actions
  class Item < LinkedRails::Actions::Item
    # Return options used by DropdownHelper#dropdown_options
    def dropdown_options(opts)
      (link_opts || {}).merge(fa: image).merge(opts)
    end
  end
end
