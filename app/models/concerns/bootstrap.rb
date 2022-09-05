# frozen_string_literal: true

module Bootstrap
  extend ActiveSupport::Concern

  included do
    before_create :build_default_forum
    after_create :tenant_create
    after_create :create_default_groups
    after_create :create_default_menu_items
    after_create :create_system_vocabs
  end

  private

  def create_admins_group
    admin_group = create_default_group(:admin, require_confirmation: true)
    admin_group.grants.create!(grant_set: GrantSet.administrator, edge: self)
    create_membership(admin_group, publisher, creator) unless creator.reserved?
  end

  def build_default_forum
    self.primary_container_node = Forum.new(
      is_published: true,
      publisher: publisher,
      creator: creator,
      create_menu_item: false,
      name: display_name,
      owner_type: 'Forum',
      parent: self,
      url: 'forum'
    )
  end

  def create_default_group(name, deletable: false, require_confirmation: false)
    groups.create!(
      name: I18n.t("groups.default.#{name}.name"),
      name_singular: I18n.t("groups.default.#{name}.name_singular"),
      deletable: deletable,
      require_confirmation: require_confirmation
    )
  end

  def create_default_groups
    ActsAsTenant.with_tenant(self) do
      create_admins_group
      create_members_group
    end
  end

  def create_default_menu_items
    ActsAsTenant.with_tenant(self) do
      navigations_menu_items.create!(edge: self)
      navigations_menu_items.create!(
        href: feeds_iri(self),
        label: 'menus.default.activity'
      )
    end
  end

  def create_members_group
    members_group = create_default_group(:members)
    members_group.grants.create!(grant_set: GrantSet.participator, edge: primary_container_node)
  end

  def create_membership(group, user, profile)
    group_membership =
      CreateGroupMembership.new(
        group,
        attributes: {member_id: profile.id},
        options: {user_context: UserContext.new(user: user, profile: profile)}
      ).resource
    group_membership.save!(validate: false)
    group_membership
  end

  def create_system_vocabs
    ActsAsTenant.with_tenant(self) do
      VocabSyncWorker.perform_async if Group.public.present?
    end
  end

  def tenant_create
    create_tenant!(root_id: uuid, iri_prefix: iri_prefix)
  end
end
