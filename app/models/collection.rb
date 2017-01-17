# frozen_string_literal: true
class Collection
  include ActiveModel::Model, ActiveModel::Serialization, PragmaticContext::Contextualizable,
          Ldable, Pundit
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers

  attr_accessor  :association, :filter, :current_profile, :current_user, :page, :pagination,
                 :parent, :potential_action, :title, :uri
  attr_writer :association_class

  contextualize_as_type 'argu:Collection'
  contextualize_with_id(&:id)
  contextualize :title, as: 'schema:name'
  contextualize :total_count, as: 'argu:totalCount'

  def as_json(options = {})
    super(options.merge(except: ['association_class']))
  end

  def id
    query_values = "?#{query_opts.to_param}" if query_opts.present?
    "#{(uri || url_for([parent, association_class, protocol: :https]))}#{query_values}"
  end

  def members
    return if paginate? || include_views?
    if association == :votes
      @members ||= policy_scope(
        parent
          .send(association)
          .joins(:edge)
          .includes(voter: :profileable, edge: :parent)
          .where(filter_query)
      ).page(page)
    else
      @members ||= policy_scope(
        parent
          .send(association)
          .joins(:edge)
          .includes(creator: :profileable, edge: :parent)
          .where(filter_query)
      ).page(page)
    end
  end

  def views
    if paginate?
      return [
        Collection.new(
          page: 1,
          parent: parent,
          association: association,
          association_class: association_class,
          filter: filter,
          uri: uri
        )
      ]
    end
    return unless include_views?
    @views
  end

  def views=(views)
    @views = views.map do |view|
      view.parent = parent
      view.association = association
      view.association_class = association_class
      view.uri = uri
      view.filter = (view.filter || {}).merge(filter) if filter.present?
      view
    end
  end

  def title
    @title || I18n.t("#{association_class.name.tableize}.plural", default: association_class.name.tableize.humanize)
  end

  def total_count
    members&.count || parent_total_count
  end

  private

  def association_class
    @association_class ||= association.to_s.classify.constantize
  end

  def include_views?
    @views&.map(&:id)&.none? { |view_id| id.include?(view_id) }
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
    (pagination || pagination.nil? && filter.present?) && page.nil?
  end

  def parent_total_count
    parent.try(association).try(:joins, :edge).try(:where, filter_query).try(:count)
  end

  def pundit_user
    UserContext.new(
      @current_user,
      @current_profile,
      nil
    )
  end

  def query_opts
    opts = {}
    opts[:page] = page if page.present?
    opts[:filter] = filter if filter.present?
    opts
  end
end
