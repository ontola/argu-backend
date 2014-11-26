##
# Renders a collection of models in one or more columns
# @param #HashWithIndifferentAccess With column names as keys
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
      else 'column_renderer/show'
    end
    render partial: partial, locals: {model: columns}.merge({options: options})
  end

  #
  def header(options)
    content_tag :header do
      content_tag :h1, options[:header]
    end
  end

  # This generates the translations for the header text, e.g. "arguments.header.pro"
  def header_text(options, key)
    I18n.t("#{options[:collection_model].to_s.pluralize.downcase}.header.#{key}")
  end

  def show_new_buttons(options, key)
    if options[:buttons_url].present?
      render partial: 'column_renderer/button', locals: options.merge({pro: key})
      #TODO change color for argument sides (pro vs con) and type (argument / question / motion)
    end
  end

  def buttons_url(model)
    if model[:buttons_param].present?
      merge_query_parameter(model[:buttons_url], {model[:buttons_param] => model[:pro]})
    else
      model[:buttons_url]
    end
  end

end