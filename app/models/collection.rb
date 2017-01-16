# frozen_string_literal: true
class Collection
  include ActiveModel::Model, ActiveModel::Serialization, PragmaticContext::Contextualizable,
          Ldable, Pundit
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers

  attr_accessor :association, :association_class, :filter, :name, :page, :pagination,
                :parent, :potential_action, :title, :url_constructor, :user_context

  alias pundit_user user_context

  contextualize_as_type 'argu:Collection'
  contextualize_with_id(&:id)
  contextualize :title, as: 'schema:name'

  # prevents a `stack level too deep`
  def as_json(options = {})
    super(options.merge(except: ['association_class']))
  end

  def id
    query_values = "?#{query_opts.to_param}" if query_opts.present?
    "#{(uri || url_for([parent, association_class, protocol: :https]))}#{query_values}"
  end

  def members
    return if paginate? || filter?
    includes = association == :votes ? {voter: :profileable, edge: :parent} : {creator: :profileable, edge: :parent}
    @members ||= policy_scope(
      parent
        .send(association)
        .joins(:edge)
        .includes(includes)
        .where(filter_query)
    ).page(page)
  end

  def views
    if filter?
      return association_class.filter_options.map do |key, values|
        values[:values].map { |value| child_with_options(filter: {key => value[0]}) }
      end.flatten
    elsif paginate?
      [child_with_options(page: 1)]
    end
  end

  def title
    I18n.t("#{association_class.name.tableize}.collection.#{filter.values.join('.')}",
           default: I18n.t("#{association_class.name.tableize}.plural",
                           default: association_class.name.tableize.humanize))
  end

  private

  def child_with_options(options)
    options = {
      user_context: user_context,
      filter: filter,
      page: page
    }.merge(options)
    parent.collection_for(name, options)
  end

  def filter?
    association_class.filter_options.present? && filter.empty?
  end

  def filter_query
    return if filter.nil?
    filter_values = []
    [
      filter.map do |k, v|
        key = association_class.filter_options.fetch(k)[:key] || k
        value = association_class.filter_options.fetch(k)[:values].try(:[], v.to_sym) || v
        if value.is_a?(String) && value.include?('NULL')
          [key, value].join(' IS ')
        else
          filter_values <<  value
          [key, '?'].join(' = ')
        end
      end.join(' AND '),
      *filter_values
    ]
  end

  def paginate?
    pagination && page.nil?
  end

  def query_opts
    opts = {}
    opts[:page] = page if page.present?
    opts[:filter] = filter if filter.present?
    opts
  end
end
