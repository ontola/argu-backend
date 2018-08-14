# frozen_string_literal: true

module ChildHelper
  def child_instance(parent, klass)
    child = klass.new(child_attrs(parent, klass))
    if child.is_a?(Edge)
      child.creator = Profile.new(are_votes_public: true) if child.respond_to?(:creator=)
      child.persisted_edge = parent.persisted_edge
      grant_tree.cache_node(parent.persisted_edge) if respond_to?(:grant_tree)
    else
      child = klass.new(child_attrs(parent, klass))
    end
    child
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def child_attrs(parent, raw_klass)
    case raw_klass.to_s
    when 'Discussion'
      {forum: parent}
    when 'Export', 'Favorite', 'GrantTree'
      {edge: parent}
    when 'Grant'
      if parent.is_a?(Group)
        {edge: parent.page, group: parent}
      else
        {edge: parent}
      end
    when 'GroupMembership'
      {group: parent}
    when 'Group'
      {page: parent}
    when 'MediaObject'
      {about: parent}
    when 'Decision'
      {state: 'forwarded', parent: parent}
    when 'Shortname'
      {owner: parent}
    else
      raw_klass <= Edge ? {parent: parent} : {}
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
