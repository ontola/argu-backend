##
# Renders a collection of models in one or more columns
# @param #HashWithIndifferentAccess As: {column_key: {collection: items, *options}}
# @param :header, title of the main header
# @param :buttons_url, string for the button beneath a column
# @param :buttons_param, if present, adds the column name as a parameter to buttons_url
# @param :collection_model, model of the collection, used for translations @todo: fix this hack so this param is obsolete
module ColumnRendererHelper
  def render_columns(columns, options = {})
    partial = case columns
      when Motion then 'motions/show'
      when Argument then 'arguments/show'
      when Vote then 'votes/show'
      when Opinion then 'opinions/show'
      when Question then 'questions/show'
      when Comment then 'comments/show'
      when GroupResponse then 'group_responses/show'
      else 'column_renderer/show'
    end

    if partial == 'column_renderer/show'
      columns.each do |k,v|
        columns[k] = options.merge(v||{})
      end
    end

    render partial: partial, locals: {model: columns}.merge({options: options})
  end

  #
  def header(options)
    if !(defined?(options[:header]) && options[:header] == false)
        content_tag :header do
          content_tag :h1, options[:header]
        end
    end
  end

  # This generates the translations for the header text, e.g. "arguments.header.pro"
  def header_text(options, key)
    if !(defined?(options[:header_text]) && options[:header_text] == false)
      I18n.t("#{options[:collection_model].to_s.pluralize.downcase}.header.#{key}")
    end
  end

  def show_new_buttons(options, key)
    if options[:buttons_form_on_empty] && options[:collection].blank?
      render partial: "#{options[:collection_model].name.tableize}/form", locals: options.merge({pro: key, resource: options[:collection_model].new(pro: key, motion: @motion)})
    elsif options[:show_new_buttons] != false && options[:buttons_url].present?
      render partial: 'column_renderer/button', locals: options.merge({pro: key})
    end
  end

  # Stitches the url for a button beneath a column together
  def buttons_url(model)
    if model[:buttons_param].present?
      merge_query_parameter(model[:buttons_url], {model[:buttons_param] => model[:pro]})
    else
      model[:buttons_url]
    end
  end

  # Used to render a collection if it contains items
  def render_collection_if_present(model, key, &block)
    (model[key][:collection] || model[key.to_s][:collection]).each(&block) if (model[key][:collection] || model[key.to_s][:collection])
  end

end