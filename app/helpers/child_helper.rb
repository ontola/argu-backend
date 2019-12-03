# frozen_string_literal: true

module ChildHelper
  module_function

  def child_instance(parent, klass)
    child = klass.new(child_attrs(parent, klass))
    prepare_edge_child(parent, child) if child.is_a?(Edge)
    child
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
  def child_attrs(parent, raw_klass) # rubocop:disable Metrics/AbcSize
    case raw_klass.to_s
    when 'CustomMenuItem'
      {resource: parent}
    when 'Discussion'
      {forum: parent}
    when 'Export', 'Favorite', 'GrantTree'
      {edge: parent}
    when 'Grant'
      if parent.is_a?(Group)
        {group: parent}
      else
        {edge: parent}
      end
    when 'GroupMembership'
      {group: parent}
    when 'Group'
      if parent.is_a?(Grant)
        {page: parent.edge.root}
      else
        {page: parent}
      end
    when 'MediaObject', 'ImageObject'
      {about: parent}
    when 'Decision'
      {state: 'forwarded', parent: parent}
    when 'Shortname'
      {owner: parent, primary: false}
    when 'EmailAddress'
      {user: parent}
    when 'Publication'
      {publishable: parent}
    when 'Comment'
      parent.is_a?(Comment) ? {parent: parent.parent} : {parent: parent}
    when 'Placement', 'HomePlacement'
      {placeable: parent}
    when 'Widget'
      {owner: parent}
    when 'Profile'
      {profileable: parent}
    else
      raw_klass <= Edge && parent.is_a?(Edge) ? {parent: parent} : {}
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength

  def prepare_edge_child(parent, child)
    child.creator = Profile.new(are_votes_public: true) if child.respond_to?(:creator=)
    child.persisted_edge = parent.try(:persisted_edge)
    child.is_published = true
    grant_tree.cache_node(parent.try(:persisted_edge)) if respond_to?(:grant_tree)
  end
end
