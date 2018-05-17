# frozen_string_literal: true

##
# Renders a collection of models in one or more columns
module ColumnRendererHelper
  # @param [HashWithIndifferentAccess] options As: {column_key: {collection: items, *options}}
  # @option options [String] :header title of the main header
  # @option options [String] :buttons_url string for the button beneath a column
  # @option options [Symbol] :buttons_param if present, adds the column name as a parameter to buttons_url
  # @option options [ActiveRecord::Base] :collection_model model of the collection, used for
  #   translations @todo: fix this hack so this param is obsolete
  # @option options [String] :partial The partial path that should be used to render the individual items
  def render_columns(columns, options = {})
    return if columns.nil?
    columns = columns.owner if columns&.is_a?(Edge)
    partial = columns.is_a?(ActiveRecord::Base) && options[:partial] || column_partial(columns)

    if partial == 'column_renderer/show'
      columns.each do |k, v|
        columns[k] = options.merge(v || {})
      end
    end

    model = columns.is_a?(Edge) ? columns.owner : columns
    render partial: partial, locals: {model: model}.merge(options: options.with_indifferent_access)
  end

  def column_partial(columns)
    included_models = [Motion, ProArgument, ConArgument, Vote, Question,
                       Comment, BlogPost, Decision, LinkedRecord]
    if included_models.include?(columns.class)
      "#{columns.class.base_class.name.tableize}/show"
    else
      'column_renderer/show'
    end
  end

  def button_box(params)
    {
      tag: 'div',
      class: 'btn--huge btn--huge--container'
    }.merge(params.except(:collection))
  end

  def header(options)
    return if defined?(options[:header]) && options[:header] == false
    content_tag :header do
      content_tag :h2, options[:header]
    end
  end

  # This generates the translations for the header text, e.g. "arguments.header.pro"
  def header_text(options, key)
    if !defined?(options[:header_text]) || options[:header_text].blank? || options[:header_text] == false
      I18n.t("#{options[:collection_model].class_name}.header.#{key}")
    elsif defined?(options[:header_text]) && options[:header_text].present?
      options[:header_text][key]
    end
  end

  def show_new_buttons(options, key)
    if options[:buttons_form_on_empty] && options[:collection].blank?
      render partial: "#{options[:collection_model].name.tableize}/form",
             locals: options.merge(pro: key, resource: options[:collection_model].new(pro: key, motion: @motion))
    elsif options[:show_new_buttons] != false && options[:buttons_url].present?
      render partial: 'column_renderer/button', locals: options.merge(pro: key)
    end
  end

  def sort_buttons(options)
    return unless options[:sort_buttons]
    content_tag :div, class: 'btns-list--subtle btns-sort-motions' do
      content_tag :li do
        content_tag :ul do
          react_component_store 'HyperDropdown', props: options[:sort_buttons]
        end
      end
    end
  end

  # Stitches the url for a button beneath a column together
  def buttons_url(model)
    if model[:buttons_param].present?
      merge_query_parameter(model[:buttons_url], model[:buttons_param] => model[:pro])
    else
      model[:buttons_url]
    end
  end

  # Used to render a collection if it contains items
  def render_collection_if_present(model, key, &block)
    return unless model[key][:collection] || model[key.to_s][:collection]
    (model[key][:collection] || model[key.to_s][:collection]).each(&block)
  end
end
