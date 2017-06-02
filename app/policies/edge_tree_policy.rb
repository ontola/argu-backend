# frozen_string_literal: true
class EdgeTreePolicy < RestrictivePolicy
  class Scope < RestrictivePolicy::Scope
    def class_name
      self.class.name.split('Policy')[0]
    end

    def resolve
      return scope.published.untrashed if staff?
      scope
        .published
        .untrashed
        .joins("LEFT JOIN forums ON #{class_name.tableize}.forum_id = forums.id")
        .where("#{class_name.tableize}.forum_id IS NULL OR #{class_name.tableize}.forum_id IN (?) "\
               'OR forums.visibility = ?',
               user.profile.forum_ids,
               Forum.visibilities[:open])
    end
  end

  module Roles
    def open
      1
    end

    def member
      3
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

    def super_admin
      10
    end

    def is_member?
      return if persisted_edge.nil?
      member if (user.profile.group_ids & persisted_edge.granted_group_ids('member')).any?
    end

    def is_creator?
      creator if record.creator.present? && record.creator == actor
    end

    def is_moderator?
      c_model = context_forum
      return if user.guest? || c_model.nil?
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
      return manager if (user.profile.group_ids & persisted_edge.granted_group_ids('manager')).any?
      is_super_admin?
    end

    def is_super_admin?
      return if persisted_edge.nil?
      return super_admin if (user.profile.group_ids & persisted_edge.granted_group_ids('super_admin')).any?
    end

    def is_manager_up?
      is_manager? || is_super_admin? || staff?
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
    if (is_manager? || staff?) && record.is_publishable? && !record.is_a?(Decision) &&
        (!record.is_published? || record.argu_publication&.reactions?)
      attributes.append(:mark_as_important)
    end
    attributes.append(edge_attributes: Pundit.policy(context, record.edge).permitted_attributes) if record.try(:edge)
    attributes
  end

  def permitted_publish_types
    Publication.publish_types
  end

  def change_owner?
    rule is_super_admin?, staff?
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
    rule is_member?, is_moderator?, is_super_admin?, staff?
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
    rule is_moderator?, is_manager?, is_super_admin?, staff?
  end

  def feed?
    rule show?
  end

  # Move items between forums or converting items
  def move?
    staff?
  end

  def shift?
    move?
  end

  def show_unpublished?
    rule is_creator?, is_moderator?, is_manager?, is_super_admin?, staff?, service?
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

  def show?
    return show_unpublished? if has_unpublished_ancestors?
    rule is_member?, is_moderator?, is_manager?, is_super_admin?, super
  end

  private

  def parent_policy
    Pundit.policy(context, record.parent_model)
  end
end
