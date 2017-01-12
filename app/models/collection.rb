# frozen_string_literal: true
class Collection
  include ActiveModel::Model, ActiveModel::Serialization, PragmaticContext::Contextualizable,
          Ldable
  include ActionDispatch::Routing
  include Rails.application.routes.url_helpers

  attr_accessor :parent, :association, :potential_action, :title, :page, :filter, :context_type

  contextualize_as_type 'argu:Collection'
  contextualize_with_id(&:id)
  contextualize :title, as: 'schema:name'

  def id
    opts = {}
    opts[:page] = page if page.present?
    opts[:filter] = filter if filter.present?
    opts[:protocol] = :https
    url_for([parent, association, opts])
  end

  def context_type
    association.to_s.classify.constantize.contextualized_type.downcase.pluralize
  end

  def members
    return if page.nil?
    if association == :arguments
      parent
        .send(association)
        .includes(creator: :profileable, edge: :parent)
        .where(filter_query)
        .page(page)
    else
      parent
        .send(association)
        .includes(voter: :profileable, edge: :parent)
        .where(filter_query)
        .page(page)
    end
  end

  def filter_query
    association.to_s.classify.constantize.filter_query(filter)
  end

  def paginate?
    page.nil? && filter.present?
  end

  def views
    return [Collection.new(page: 1, parent: parent, association: association, filter: filter)] if paginate?
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
end
