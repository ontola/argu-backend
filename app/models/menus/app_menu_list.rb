# frozen_string_literal: true

class AppMenuList < ApplicationMenuList # rubocop:disable Metrics/ClassLength
  include SettingsHelper
  include LanguageHelper

  has_menu :info,
           label: LinkedRails.translations(-> { I18n.t('about.info') }),
           image: 'fa-info',
           menus: -> { info_menu_items }
  has_menu :user,
           label: -> { user_context.user.display_name },
           image: -> { user_context.user.default_profile_photo.thumbnail },
           menus: -> { user_menu_items }
  has_menu :session,
           menus: -> { session_links }
  has_menu :navigations,
           menus: -> { navigations_menu_items }
  has_menu :settings,
           iri_base: -> { ActsAsTenant.current_tenant.iri_path },
           menus: -> { setting_menu_items }

  def iri_template
    uri_template('menu_lists_iri')
  end

  private

  def container_nodes
    @container_nodes ||=
      EdgePolicy::Scope.new(user_context, user_context.user.container_nodes)
        .resolve
        .includes(:default_profile_photo, :shortname)
  end

  def info_menu_items
    [
      *custom_menu_items(:info, ActsAsTenant.current_tenant),
      powered_by_link
    ]
  end

  def language_menu_item
    menu_item(
      :language,
      label: I18n.t('set_language'),
      href: iri_from_template(:languages_iri)
    )
  end

  def navigations_menu_items # rubocop:disable Metrics/MethodLength
    [
      menu_item(
        :home,
        image: ActsAsTenant.current_tenant.home_menu_image,
        label: ActsAsTenant.current_tenant.home_menu_label,
        href: ActsAsTenant.current_tenant.iri
      ),
      *custom_menu_items(:navigations, ActsAsTenant.current_tenant),
      menu_item(
        :settings,
        image: 'fa-gear',
        href: settings_iri(ActsAsTenant.current_tenant),
        policy: :update?,
        policy_resource: ActsAsTenant.current_tenant
      ),
      new_container_node_item
    ]
  end

  def navigation_item(record)
    menu_item(
      record.url.to_sym,
      href: record.iri,
      label: record.display_name,
      image: record.try(:default_profile_photo),
      policy: :show?,
      policy_resource: record
    )
  end

  def new_container_node_item
    menu_item(
      :new_component,
      image: 'fa-plus',
      policy: :create_child?,
      policy_arguments: %i[forums],
      policy_resource: ActsAsTenant.current_tenant,
      href: RDF::DynamicURI(path_with_hostname(expand_uri_template(:new_container_node_iri)))
    )
  end

  def powered_by_link
    return if ActsAsTenant.current_tenant.enable_white_label?

    menu_item(:powered_by, label: I18n.t('about.powered_by'), href: RDF::URI('https://ontola.io/nl/webdevelopment'))
  end

  def public_pages
    return @public_pages if instance_variable_defined?('@public_pages')

    page_ids =
      Forum
        .joins(:parent)
        .where(edges: {uuid: Setting.get('suggested_forums')&.split(',')})
        .pluck('parents_edges.uuid')
    @public_pages ||=
      Page.where(uuid: page_ids).includes(:shortname, profile: :default_profile_photo)
  end

  def resource
    ActsAsTenant.current_tenant
  end

  def session_links # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    items = []
    items << menu_item(
      :sign_in,
      label: I18n.t('actions.sessions.create.label'),
      href: LinkedRails.iri(path: 'u/sign_in')
    )
    items << menu_item(
      :password,
      label: I18n.t('devise.passwords.new.header'),
      href: LinkedRails.iri(path: 'users/password/new')
    )
    items << menu_item(
      :confirmation,
      label: I18n.t('devise.confirmations.send'),
      href: LinkedRails.iri(path: 'users/confirmation/new')
    )
    items << menu_item(
      :locked,
      label: I18n.t('devise.unlocks.new.header'),
      href: LinkedRails.iri(path: 'users/unlock/new')
    )
    items
  end

  def setting_menu_items # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    [
      setting_item(:general, label: I18n.t('pages.settings.menu.general'), href: edit_iri(ActsAsTenant.current_tenant)),
      setting_item(
        :container_nodes,
        label: I18n.t('pages.settings.menu.container_nodes'),
        href: collection_iri(ActsAsTenant.current_tenant, :container_nodes, display: :settingsTable)
      ),
      setting_item(
        :groups,
        label: I18n.t('pages.settings.menu.groups'),
        href: collection_iri(ActsAsTenant.current_tenant, :groups, display: :settingsTable)
      ),
      setting_item(
        :shortnames,
        label: I18n.t('pages.settings.menu.shortnames'),
        href: collection_iri(ActsAsTenant.current_tenant, :shortnames, display: :settingsTable)
      ),
      setting_item(
        :custom_menu_items,
        label: I18n.t('custom_menu_items.plural'),
        href: collection_iri(ActsAsTenant.current_tenant, :custom_menu_items, display: :table)
      ),
      setting_item(
        :banners,
        label: I18n.t('banners.plural'),
        href: collection_iri(ActsAsTenant.current_tenant, :banners, display: :table)
      )
    ]
  end

  def setting_item_opts(tag, opts)
    {policy_resource: ActsAsTenant.current_tenant}.merge(super)
  end

  def sign_out_menu_item
    menu_item(
      :signout,
      action: NS::LIBRO['actions/logout'],
      label: I18n.t('sign_out'),
      href: RDF::DynamicURI(sign_out_url)
    )
  end

  def user_base_items # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    if user_context.user.setup_finished?
      [
        menu_item(
          :show, label: I18n.t('show_type', type: I18n.t('users.type')), href: user_context.user.menu(:profile).iri
        ),
        menu_item(
          :profile, label: I18n.t('profiles.edit.title'), href: user_context.user.menu(:profile).iri(fragment: :profile)
        )
      ]
    else
      [menu_item(:setup, label: I18n.t('profiles.setup.link'), href: RDF::DynamicURI(setup_users_url))]
    end
  end

  def user_forum_management_item
    menu_item(
      :forums,
      label: I18n.t('forums.management.title'),
      href: RDF::DynamicURI(forums_user_url(user_context.user))
    )
  end

  def user_menu_items
    return [language_menu_item] if user_context.user.guest?

    items = user_base_items
    items << user_settings_item
    items << language_menu_item
    items << sign_out_menu_item
    items
  end

  def user_settings_item
    menu_item(
      :settings,
      label: I18n.t('users.settings.title'),
      href: user_context.user.menu(:profile).iri(fragment: :settings)
    )
  end
end
