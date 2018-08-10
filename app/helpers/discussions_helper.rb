# frozen_string_literal: true

module DiscussionsHelper
  def gallery_props(resource)
    files =
      resource
        .attachments
        .map do |a|
        {src: a.url, caption: a.description.presence, thumbnail: a.thumbnail, type: a.type, embed_url: a.embed_url}
      end
    {files: files}
  end

  # Checks if the user is able to start a top-level discussion in the current context/tenant
  # @return [Boolean] Whether the user can new? any discussion object
  def can_start_discussion?(record)
    %i[questions motions].any? { |model| policy(record).create_child?(model) }
  end

  def discussion_invite_groups(resource)
    group_ids =
      user_context
        .grant_tree
        .granted_group_ids(resource, action: 'show', resource_type: resource.owner_type)
        .select(&:positive?)
    Group
      .find(group_ids)
      .map do |group|
        grant_sets_string =
          user_context
            .grant_tree
            .grant_sets(resource, group_ids: [group.id])
            .map { |grant_set| t("roles.types.#{grant_set}") }
            .join(', ')
        {label: "#{group.name} (#{t('roles.may')} #{grant_sets_string})", value: group.id}
      end
      .append(label: "+ #{t('groups.new')}", value: -1)
  end

  def discussion_invite_props(resource)
    {
      createTokenUrl: '/tokens',
      createGroupUrl: collection_iri(resource.root, :groups),
      currentActor: current_user.iri,
      defaultRole: GrantSet.participator.id,
      forumEdge: resource.ancestor(:forum).uuid,
      forumName: resource.ancestor(:forum).display_name,
      forumNames: resource.root.forums.map(&:name).join(', '),
      groups: discussion_invite_groups(resource),
      managedProfiles: managed_profiles_list,
      message: t('tokens.discussion.default_message', resource: resource.display_name),
      pageEdge: resource.root_id,
      resource: resource.canonical_iri,
      roles: GrantSet
               .selectable
               .pluck(:title, :id)
               .map { |title, id| {label: t("roles.types.#{title}").capitalize, title: title, value: id} }
    }
  end

  def move_options(resource)
    case resource
    when Motion
      resource.root.forums.flat_map do |forum|
        [["Forum #{forum.display_name}", forum.uuid, style: 'font-weight: bold']].concat(
          forum.questions.untrashed.map { |question| ["- #{question.display_name}", question.uuid] }
        )
      end
    when Forum
      Page.all.includes(:profile).map { |page| [page.display_name, page.uuid] }
    else
      resource.root.forums.map do |forum|
        ["Forum #{forum.display_name}", forum.uuid]
      end
    end
  end
end
