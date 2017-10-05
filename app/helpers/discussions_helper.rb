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
    %i[questions motions projects].any? { |model| policy(record).create_child?(model) }
  end

  def discussion_invite_groups(resource)
    resource
      .edge
      .granted_groups(:spectator)
      .where('groups.id > 0')
      .map do |group|
        {
          label: "#{group.name} (#{t('roles.may')} #{t("roles.types.#{Grant.roles.key(group.role)}")})",
          value: group.id
        }
      end
      .append(label: t('groups.new'), value: -1)
  end

  def discussion_invite_props(resource)
    {
      createTokenUrl: '/tokens',
      createGroupUrl: page_groups_url(resource.parent_model(:page)),
      currentActor: current_user.context_id,
      forumEdge: resource.parent_edge(:forum).id,
      forumName: resource.parent_model(:forum).display_name,
      forumNames: resource.parent_model(:page).forums.pluck(:name).join(', '),
      groups: discussion_invite_groups(resource),
      managedProfiles: managed_profiles_list,
      message: t('tokens.discussion.default_message', resource: resource.display_name),
      pageEdge: resource.parent_edge(:page).id,
      resource: resource.context_id,
      roles: Grant.roles.except('manager', 'staff').map do |role, _|
        {label: t("roles.types.#{role}").capitalize, value: role}
      end
    }
  end
end
