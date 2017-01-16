# frozen_string_literal: true
class Collection
  include ActiveModel::Model, ActiveModel::Serialization, PragmaticContext::Contextualizable,
          Ldable, Pundit
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers

  attr_accessor  :association, :filter, :current_profile, :current_user, :page, :pagination,
                 :parent, :potential_action, :title
  attr_writer :association_class

  contextualize_as_type 'argu:Collection'
  contextualize_with_id(&:id)
  contextualize :title, as: 'schema:name'

  def as_json(options = {})
    super(options.merge(except: ['association_class']))
  end

  def id
    opts = {}
    opts[:page] = page if page.present?
    opts[:filter] = filter if filter.present?
    opts[:protocol] = :https
    url_for([parent, association_class, opts])
  end

  def members
    return if paginate? && page.nil?
    if association == :votes
      policy_scope(
        parent
          .send(association)
          .includes(voter: :profileable, edge: :parent)
          .where(filter_query)
          .page(page)
      )
    else
      policy_scope(
        parent
          .send(association)
          .includes(creator: :profileable, edge: :parent)
          .where(filter_query)
          .page(page)
      )
    end
  end

  def views
    if paginate?
      return [Collection.new(page: 1, parent: parent, association: association, filter: filter, pagination: pagination)]
    end
    return if @views&.map(&:id)&.any? { |view_id| id.include?(view_id) }
    @views
  end

  def views=(views)
    @views = views.map do |view|
      view.parent = parent
      view.association = association
      view.filter = (view.filter || {}).merge(filter) if filter.present?
      view
    end
  end

  def title
    @title || I18n.t("#{association_class.name.tableize}.plural", default: association_class.name.tableize.humanize)
  end

  private

  def association_class
    @association_class ||= association.to_s.classify.constantize
  end

  def pundit_user
    UserContext.new(
      @current_user,
      @current_profile,
      nil
    )
  end

  def filter_query
    return if filter.nil?
    filter.map do |key, value|
      [
        association_class.filter_options.fetch(key)[:key] || key,
        association_class.filter_options.fetch(key)[:values].try(:[], value.to_sym) || value
      ]
    end.to_h
  end

  def paginate?
    pagination.present? && page.nil? && filter.present?
  end
end
