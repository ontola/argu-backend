# frozen_string_literal: true

class EdgePolicy < RestrictivePolicy
  class Scope < EdgeTreePolicy::Scope
    def class_name
      self.class.name.split('Policy')[0]
    end

    def resolve
      scope.where("edges.path ? #{path_array}").active
    end
  end
  include ChildOperations

  delegate :persisted_edge, to: :record
  attr_reader :grant_tree

  def initialize(context, record)
    super
    raise('No edge available in policy') unless record
    @grant_tree = context.grant_tree_for(record)
  end

  %i[spectator participator moderator administrator staff].each do |role|
    define_method "#{role}?" do
      return instance_variable_get("@#{role}") if instance_variable_defined?("@#{role}")
      instance_variable_set("@#{role}", has_grant_set?(role))
    end
  end

  def has_expired_ancestors?
    grant_tree.expired?(persisted_edge)
  end

  def has_trashed_ancestors?
    grant_tree.trashed?(persisted_edge)
  end

  def has_unpublished_ancestors?
    grant_tree.unpublished?(persisted_edge)
  end

  def has_grant?(action)
    group_ids =
      grant_tree
        .granted_group_ids(
          persisted_edge,
          action: action,
          resource_type: class_name,
          parent_type: record&.parent&.owner_type
        )
    (group_ids & user.profile.group_ids).any?
  end

  def has_grant_set?(grant_set)
    return false if grant_tree.nil?
    grant_tree
      .grant_sets(persisted_edge, group_ids: user.profile.group_ids)
      .include?(grant_set.to_s)
  end

  def permitted_attribute_names
    attributes = super
    attributes.append(:mark_as_important) if mark_as_important?
    attributes.concat %i[id expires_at] if expires_at?
    attributes.concat([:url, shortname_attributes: %i[shortname id]]) if shortname?
    attributes.append(argu_publication_attributes: argu_publication_attributes) if record.is_publishable?
    attributes.append(placements_attributes: %i[id lat lon placement_type zoom_level _destroy])
    append_default_photo_params(attributes) if %w[Forum Question Motion].include?(record.owner_type)
    append_attachment_params(attributes) if %w[Question Motion BlogPost].include?(record.owner_type)
    attributes
  end

  def convert?
    false
  end

  def contact?
    administrator? || staff?
  end

  def move?
    false
  end

  def shift?
    move?
  end

  def show?
    return show_unpublished? if has_unpublished_ancestors?
    has_grant?(:show)
  end

  def create?
    return create_expired? if has_expired_ancestors?
    return create_trashed? if has_trashed_ancestors?
    has_grant?(:create)
  end

  def trash?
    has_grant?(:trash)
  end
  alias bin? trash?

  def untrash?
    trash?
  end
  alias unbin? trash?

  def update?
    is_creator? || has_grant?(:update)
  end

  def destroy?
    return super if record.children_counts.values.map(&:to_i).sum.positive?
    is_creator? || has_grant?(:destroy)
  end

  def follow?
    show?
  end

  def log?
    update?
  end

  def feed?
    show?
  end

  def invite?
    false
  end

  def statistics?
    has_grant?(:update)
  end

  def shortname?
    new_record? || update?
  end

  private

  def argu_publication_attributes
    argu_publication_attributes = %i[id draft]
    argu_publication_attributes.append(:published_at) if moderator? || administrator? || staff?
    argu_publication_attributes
  end

  def cache_action(action, val)
    user_context.cache_key(record.id, action, val)
  end

  def check_action(action)
    user_context.check_key(record.id, action)
  end

  def class_name
    self.class.name.split('Policy')[0]
  end

  def create_expired?
    nil
  end

  def create_trashed?
    false
  end

  def expires_at?
    %w[Motion Question].include?(record.owner_type) && (moderator? || administrator? || staff?)
  end

  def is_creator?
    return if record.creator.blank?
    record.publisher_id == user.id || user.managed_profile_ids.include?(record.creator_id)
  end

  def mark_as_important?
    (moderator? || administrator? || staff?) &&
      record.is_publishable? &&
      !record.is_a?(Decision) &&
      (!record.is_published? || record.argu_publication&.reactions?)
  end

  def parent_policy(type = nil)
    Pundit.policy(context, record.ancestor(type))
  end

  def show_unpublished?
    update?
  end
end
