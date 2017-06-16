# frozen_string_literal: true

module DropdownHelper
  def dropdown_options(title, sections, opts = {})
    options = {
      title: title,
      sections: sections
    }
    options.merge opts
  end

  def dropdown_menu(resource, menu_tag, trigger_opts: {}, item_opts: {})
    menu = resource.menu(user_context, menu_tag)
    link_items = menu.menus.map do |menu_item|
      item(
        menu_item.type || 'link',
        menu_item.label,
        menu_item.href,
        menu_item.dropdown_options(trigger_opts)
      )
    end
    return if link_items.empty?
    content_tag :li do
      content_tag :ul do
        react_component 'HyperDropdown',
                        dropdown_options(
                          menu.label,
                          [{title: menu.description, items: link_items.compact}],
                          menu.dropdown_options(item_opts)
                        ),
                        prerender: true
      end
    end
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
    item[:fa] = "fa-#{opts.delete :fa}" if opts[:fa].present? && !opts[:fa].include?('fa-')
    item.merge(opts)
  end

  def link_item(title, url, opts = {})
    item('link', title, url, opts)
  end
end
