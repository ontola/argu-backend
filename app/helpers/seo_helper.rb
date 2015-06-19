module SeoHelper

  def connected_web(options)
    if request.env['HTTP_X_PJAX']
      content_tag(:div, options_hash_to_meta_tags(options), id: 'meta_content')
    else
      content_for :connected_web, options_hash_to_meta_tags(options)
    end
  end

  def seolized_title(model)
    appendage = t("seo.#{model.class.name.downcase}.name")
    name = if model.is_a?(String)
             model
           elsif model.is_a?(Hash)
             model['title']
           else
             model.display_name
           end
    [
        name,
        (' | ' if name.present? && appendage.present?),
        appendage
    ].compact.join.capitalize
  end

  def seolized_description(model)
    appendage = t("seo.#{model.class.name.downcase}.description", title: model.display_name.downcase)
    "#{markdown_to_plaintext(model.description)} | #{t("seo.#{model.class.name.downcase}.description", title: model.display_name.downcase)}"
    [
        markdown_to_plaintext(model.description),
        (' | ' if model.description.present? && appendage.present?),
        appendage
    ].compact.join.capitalize
  end

  private

  def options_hash_to_meta_tags(options)
    META_ITEMS.map do |k, v|
      if v.is_a?(Hash) && v[:static] == true
        content_tag(:meta, nil, property: k, content: v[:content])
      else
        content_tag(:meta, nil, property: k, content: escape_once(options[v]))
      end
    end.join(' ').html_safe
  end

  META_ITEMS = {
      # HTML
      'description' => :description,
      'url' => :url,

      # Facebook
      'og:title' => :name,
      'og:description' => :description,
      'og:title' => :name,
      'og:image' => :image,

      # Twitter
      'twitter:card' => {static: true, content: 'summary'},
      'twitter:site' => {static: true, content: '@argu_co'},
      'twitter:title' => :name,
      'twitter:description' => :description,
      'twitter:image' => :image
  }

end
