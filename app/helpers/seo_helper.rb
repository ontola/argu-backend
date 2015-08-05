module SeoHelper

  def connected_web(options)
    if request.env['HTTP_X_PJAX']
      content_tag(:div, options_hash_to_meta_tags(options), id: 'meta_content')
    else
      content_for :connected_web, options_hash_to_meta_tags(options)
    end
  end

  def seolized_title(model, **options)
    appendage = t("seo.#{model.class.name.downcase}.name", **options)
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
    ].compact.join
  end

  def seolized_description(model)
    appendage = t("seo.#{model.class.name.downcase}.description", title: model.display_name.downcase)
    "#{markdown_to_plaintext(model.description)} | #{t("seo.#{model.class.name.downcase}.description", title: model.display_name)}"
    [
        markdown_to_plaintext(model.description),
        (' | ' if model.description.present? && appendage.present?),
        appendage
    ].compact.join
  end

  private

  def options_hash_to_meta_tags(options)
    META_ITEMS.map do |k, v|
      if v.is_a?(Hash)
        tag_name = v.delete(:tag_name).presence || :meta
        v = v.map { |key,val| [key, val.is_a?(Symbol) ? options[val] : v[key]] }.to_h
        v[:property] = k if tag_name.to_sym == :meta
        v[:rel] = k if tag_name.to_sym == :link
        v[:id] = k
        content_tag(tag_name, nil, v)
      else
        content_tag(:meta, nil, property: k, id: k, content: escape_once(options[v]))
      end
    end.join(' ').html_safe
  end

  META_ITEMS = {
      # HTML
      'description' => {name: 'description', content: :description},
      'url' => :url,
      'canonical' => {tag_name: 'link', href: :url, itemprop: 'url'},

      # Facebook
      'og:title' => :name,
      'og:type' => 'website',
      'og:url' => :url,
      'og:description' => :description,
      'og:title' => :name,
      'og:image' => :image,

      # Twitter
      'twitter:card' => {content: 'summary'},
      'twitter:site' => {content: '@argu_co'},
      'twitter:title' => :name,
      'twitter:description' => :description,
      'twitter:image' => :image
  }

end
