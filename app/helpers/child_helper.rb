# frozen_string_literal: true

module ChildHelper
  module_function

  def child_build_location(child, opts) # rubocop:disable Metrics/AbcSize
    lat = opts[:collection]&.filter.try(:[], NS::SCHEMA[:latitude])&.first
    lon = opts[:collection]&.filter.try(:[], NS::SCHEMA[:longitude])&.first
    zoom_level = opts[:collection]&.filter.try(:[], NS::ONTOLA[:zoomLevel])&.first
    child.build_custom_placement(lat: lat, lon: lon, zoom_level: zoom_level) if lat && lon
  end

  def child_instance(parent, klass, opts = {})
    child = klass.new(child_attrs(parent, klass, opts))
    prepare_edge_child(parent, child, opts) if child.is_a?(Edge)
    child
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
  def child_attrs(parent, raw_klass, opts = {}) # rubocop:disable Metrics/AbcSize
    case raw_klass.to_s
    when *ContainerNode.descendants.map(&:to_s)
      {locale: ActsAsTenant.current_tenant.locale, parent: parent}
    when 'CustomMenuItem'
      {resource: parent}
    when 'Discussion'
      {forum: parent}
    when 'Export', 'GrantTree'
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
      {user: opts[:user_context]&.user}
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
    when 'Vote'
      option = opts[:collection]&.filter.try(:[], NS::SCHEMA.option.to_s)&.first
      {parent: parent, option: option}
    else
      raw_klass <= Edge && parent.is_a?(Edge) ? {parent: parent} : {}
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength

  def prepare_edge_child(parent, child, opts) # rubocop:disable Metrics/AbcSize
    user_context = opts[:user_context]
    child.publisher = user_context&.user || User.new(show_feed: true) if child.respond_to?(:publisher=)
    child.creator = user_context&.actor if child.respond_to?(:creator=) && !user_context&.actor&.profileable&.guest?
    child.persisted_edge = parent.try(:persisted_edge)
    child.is_published = true
    child_build_location(child, opts)

    grant_tree.cache_node(parent.try(:persisted_edge)) if respond_to?(:grant_tree)
  end
end
