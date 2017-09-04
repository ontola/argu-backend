# frozen_string_literal: true

module DropdownHelper
  def dropdown_options(title, sections, opts = {})
    options = {
      title: title,
      sections: sections
    }
    options.merge opts
  end

  def item(type, title, url, opts = {})
    item = {
      type: type,
      title: title,
      url: url
    }

    if opts[:image].present?
      image = opts.delete(:image)
      item[:image] = {url: image} if image.present?
    end
    item[:fa] = "fa-#{opts.delete :fa}" if opts[:fa].present?
    item.merge(opts)
  end

  def link_item(title, url, opts = {})
    item('link', title, url, opts)
  end
end
