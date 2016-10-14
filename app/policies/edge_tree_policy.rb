# frozen_string_literal: true
class EdgeTreePolicy < RestrictivePolicy
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

    def is_creator?
      creator if record.creator.present? && record.creator == actor
    end

    def is_member?
      member if user && user.profile.member_of?(record)
    end

    def is_moderator?
      c_model = record.try(:forum) || context.context_model
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
      cc =
        if record.is_a?(ActiveRecord::Base)
          if record.persisted?
            record.edge.self_and_ancestors.map(&:polymorphic_tuple).compact
          elsif record.edge.parent.present?
            record.edge.parent.self_and_ancestors.map(&:polymorphic_tuple).compact
          end
        else
          []
        end
      # Match them against the set of stepups within the forum
      moderator if cc.presence && forum_stepups.where(match_record_poly_tuples(cc, 'record')).presence
    end

    def is_manager?
      nil
    end

    def is_owner?
      nil
    end

    def forum_policy
      Pundit.policy(context, record.try(:forum) || context.context_model)
    end
  end
  include Roles
  delegate :edge, to: :record

  def initialize(context, record)
    super
    raise('No edge avaliable in policy') unless edge
  end

  def permitted_attributes
    attributes = super
    attributes.append :is_trashed if !record.is_a?(Class) && trash?
    attributes
  end

  def change_owner?
    rule is_owner?, staff?
  end

  def children_classes
    record.class.reflect_on_all_associations(:has_many).map(&:name)
  end

  def convert?
    false
  end

  # Checks whether creating a child of a has_many relation is allowed
  # Initialises a child with the given attributes and checks its policy for new?
  # @param klass [Symbol] has_many association of the record
  # @param attrs [Hash] attributes used for initialising the child
  # @return [Integer, false] The user's clearance level
  def create_child?(klass, attrs = {})
    @create_child ||= {}
    @create_child[klass] ||=
      if children_classes.include?(klass)
        child = record.send(klass).new(attrs)
        child = record.edge.children.new(owner: child).owner if child.is_fertile?
        verdict = Pundit.policy(context, child).new? || false
        record.send(klass).try(:delete, child)
        verdict
      else
        false
      end
  end

  def follow?
    rule is_open?, is_member?, is_moderator?, is_owner?, staff?
  end

  # Checks whether indexing children of a has_many relation is allowed
  # Initialises a child with the given attributes and checks its policy for show?
  # @param klass [Symbol] has_many association of the record
  # @param attrs [Hash] attributes used for initialising the child
  # @return [Integer, false] The user's clearance level
  def index_children?(klass, attrs = {})
    @index_children ||= {}
    @index_children[klass] ||=
      if children_classes.include?(klass)
        child = record.send(klass).new(attrs)
        child = record.edge.children.new(owner: child).owner if child.is_fertile?
        verdict = Pundit.policy(context, child).show? || false
        record.send(klass).try(:delete, child)
        verdict
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

  def trash?
    staff?
  end

  def untrash?
    staff?
  end

  def vote?
    staff?
  end
end
