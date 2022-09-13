# frozen_string_literal: true

module Bootstrap
  extend ActiveSupport::Concern

  included do
    before_create :build_default_groups
    before_create :build_default_forum
    after_create :tenant_create
    after_create :create_default_memberships
    after_create :create_default_grants
    after_create :create_default_menu_items
    after_create :create_system_vocabs
  end

  private

  def build_default_forum # rubocop:disable Metrics/MethodLength
    ActsAsTenant.with_tenant(self) do
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
  end

  def build_default_group(name, type, deletable: false, require_confirmation: false)
    groups.build(
      name: I18n.t("groups.default.#{name}.name"),
      name_singular: I18n.t("groups.default.#{name}.name_singular"),
      deletable: deletable,
      group_type: type,
      require_confirmation: require_confirmation
    )
  end

  def build_default_groups
    ActsAsTenant.with_tenant(self) do
      build_default_group(:users, :users)
      build_default_group(:members, :custom)
      build_default_group(:admin, :admin, require_confirmation: true)
    end
  end

  def create_default_grants
    ActsAsTenant.with_tenant(self) do
      admin_group.grants.create!(grant_set: GrantSet.administrator, edge: self)
      groups.custom.first.grants.create!(grant_set: GrantSet.participator, edge: primary_container_node)
    end
  end

  def create_default_memberships
    ActsAsTenant.with_tenant(self) do
      create_membership(admin_group, publisher, creator) unless creator.reserved?
      create_membership(users_group, User.community, Profile.community)
      create_membership(users_group, User.guest, Profile.guest)
    end
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

  def create_default_menu_items
    ActsAsTenant.with_tenant(self) do
      navigations_menu_items.create!(edge: self)
      navigations_menu_items.create!(
        href: feeds_iri(self),
        label: 'menus.default.activity'
      )
    end
  end

  def create_system_vocabs
    ActsAsTenant.with_tenant(self) do
      VocabSyncWorker.perform_async
    end
  end

  def tenant_create
    create_tenant!(root_id: uuid, iri_prefix: iri_prefix)
  end
end
