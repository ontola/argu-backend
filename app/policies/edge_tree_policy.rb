# frozen_string_literal: true
class EdgeTreePolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope
    def class_name
      self.class.name.split('Policy')[0]
    end

    def forum_ids_by_access_tokens
      get_access_tokens.select { |at| at.item_type == 'Forum' }.map(&:item_id)
    end

    def resolve
      return scope.published.untrashed if staff?
      scope
        .published
        .untrashed
        .joins(:forum)
        .where("#{class_name.tableize}.forum_id IN (?) OR forums.visibility = ?",
               forum_ids_by_access_tokens.concat(user&.profile&.forum_ids || []),
               Forum.visibilities[:open])
    end

    def session
      {a_tokens: context.a_tokens}
    end
  end

  module Roles
    def open
      1
    end

    def access_token
      2
    end

    def member
      3
    end

    def creator
      4
    end

    # Not an actual role, but reserved nevertheless
    def group_grant
      5
    end

    def moderator
      6
    end

    def manager
      7
    end

    def owner
      8
    end

    def has_access_token?
      access_token if has_access_token_access_to(record)
    end

    def is_member?
      return if persisted_edge.nil?
      if ((user&.profile&.group_ids || [Group::PUBLIC_GROUP_ID]) &
        persisted_edge.granted_group_ids('member')).any? ||
          has_access_token_access_to(persisted_edge.owner)
        member
      end
    end

    def is_creator?
      creator if record.creator.present? && record.creator == actor
    end

    def is_moderator?
      c_model = context_forum
      return unless user.present? && c_model.present?
      # Stepups within the forum based if they apply to the user or one of its group memberships
      forum_stepups = c_model.stepups.where('user_id=? OR group_id IN (?)',
                                            user.id,
                                            user
                                              .profile
                                              .groups
                                              .joins(:page)
                                              .where(page: c_model.page_id)
                                              .pluck(:id))
      # Get the tuples of the entire parent chain
      cc = persisted_edge.self_and_ancestors.map(&:polymorphic_tuple).compact
      # Match them against the set of stepups within the forum
      moderator if cc.presence && forum_stepups.where(match_record_poly_tuples(cc, 'record')).presence
    end

    def is_manager?
      return if persisted_edge.nil?
      if ((user&.profile&.group_ids || [Group::PUBLIC_GROUP_ID]) &
        persisted_edge.granted_group_ids('manager')).any?
        return manager
      end
      is_owner?
    end

    def is_owner?
      return if persisted_edge.nil?
      owner if user && persisted_edge.get_parent(:page).owner.owner == user.profile
    end

    def is_manager_up?
      is_manager? || is_owner? || staff?
    end
  end
  include Roles
  delegate :edge, to: :record
  delegate :persisted_edge, :has_expired_ancestors?, :has_unpublished_ancestors?, to: :edge

  def initialize(context, record)
    super
    raise('No edge avaliable in policy') unless edge
  end

  def assert_publish_type
    return if record.edge.argu_publication&.publish_type.nil?
    assert! permitted_publish_types.include?(record.edge.argu_publication.publish_type),
            "#{record.edge.argu_publication.publish_type}?"
  end

  def context_forum
    @context_forum ||= persisted_edge.get_parent(:forum)&.owner
  end

  def permitted_attributes
    attributes = super
    if is_manager? && record.is_publishable? && !record.is_published? && !record.is_a?(Decision)
      attributes.append(:mark_as_important)
    end
    attributes.append(edge_attributes: Pundit.policy(context, record.edge).permitted_attributes) if record.try(:edge)
    attributes
  end

  def permitted_publish_types
    Publication.publish_types
  end

  def change_owner?
    rule is_owner?, staff?
  end

  def convert?
    false
  end

  # Checks whether creating a child of a given class is allowed
  # Initialises a child with the given attributes and checks its policy for new?
  # @param klass [Symbol] the class of the child
  # @param attrs [Hash] attributes used for initialising the child
  # @return [Integer, false] The user's clearance level
  def create_child?(klass, attrs = {})
    klass = klass.to_s.classify.constantize
    @create_child ||= {}
    @create_child[klass] ||=
      if klass.parent_classes.include?(record.class.name.underscore.to_sym)
        child = klass.new(attrs)
        child = record.edge.children.new(owner: child).owner if child.is_fertile?
        Pundit.policy(context, child).create? || false
      else
        false
      end
  end

  def follow?
    rule is_member?, is_moderator?, is_owner?, staff?
  end

  # Checks whether indexing children of a has_many relation is allowed
  # Initialises a child with the given attributes and checks its policy for show?
  # @param klass [Symbol] the class of the child
  # @param attrs [Hash] attributes used for initialising the child
  # @return [Integer, false] The user's clearance level
  def index_children?(klass, attrs = {})
    klass = klass.to_s.classify.constantize
    @index_children ||= {}
    @index_children[klass] ||=
      if klass.parent_classes.include?(record.class.name.underscore.to_sym)
        child = klass.new(attrs)
        child = record.edge.children.new(owner: child).owner if child.is_fertile?
        Pundit.policy(context, child).show? || false
      else
        false
      end
  end

  def log?
    rule is_moderator?, is_owner?, staff?
  end

  # Move items between forums or converting items
  def move?
    staff?
  end

  def show_unpublished?
    rule is_creator?, is_moderator?, is_manager?, is_owner?, staff?
  end

  def create_expired?
    rule staff?
  end

  def trash?
    staff?
  end

  def untrash?
    staff?
  end

  def vote?
    staff?
  end

  def session
    {a_tokens: context.a_tokens}
  end

  private

  def parent_policy
    Pundit.policy(context, record.parent_model)
  end
end
