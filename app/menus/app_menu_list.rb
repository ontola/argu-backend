# frozen_string_literal: true

require 'helpers/action_menu_items'
require 'helpers/follow_menu_items'
require 'helpers/share_menu_items'

class AppMenuList < ApplicationMenuList # rubocop:disable Metrics/ClassLength
  include SettingsHelper
  include LanguageHelper

  has_menu :session,
           menus: -> { session_menu_items }
  has_menu :user,
           label: -> { user_context.user.display_name },
           image: -> { user_context.user.default_profile_photo.thumbnail },
           menus: -> { user_menu_items }
  has_menu :navigations,
           menus: -> { navigations_menu_items }
  has_menu :settings,
           image: -> { font_awesome_iri('cogs') },
           label: -> { I18n.t('menus.default.manage') },
           iri_base: -> { ActsAsTenant.current_tenant.root_relative_iri },
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

  def session_menu_items
    [
      language_menu_item,
      sign_out_menu_item
    ]
  end

  def language_menu_item
    return if ActsAsTenant.current_tenant.hide_language_switcher?

    menu_item(
      :language,
      label: I18n.t('set_language'),
      href: User.new(singular_resource: true).action(:language).iri
    )
  end

  def navigations_menu_items
    [
      menu_item(
        :home,
        image: ActsAsTenant.current_tenant.home_menu_image,
        label: ActsAsTenant.current_tenant.home_menu_label,
        href: ActsAsTenant.current_tenant.iri
      ),
      *custom_menu_items(:navigations, ActsAsTenant.current_tenant)
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

  def resource
    ActsAsTenant.current_tenant
  end

  def setting_menu_items # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    [
      setting_item(:general, label: I18n.t('pages.settings.menu.general'), href: edit_iri(ActsAsTenant.current_tenant)),
      setting_item(
        :container_nodes,
        label: I18n.t('pages.settings.menu.container_nodes'),
        href: ContainerNode.collection_iri(display: :settingsTable)
      ),
      setting_item(
        :groups,
        label: I18n.t('pages.settings.menu.groups'),
        href: Group.collection_iri(display: :settingsTable)
      ),
      setting_item(
        :shortnames,
        label: I18n.t('pages.settings.menu.shortnames'),
        href: Shortname.collection_iri(display: :settingsTable)
      ),
      setting_item(
        :custom_menu_items,
        label: CustomMenuItem.plural_label,
        href: CustomMenuItem.collection_iri
      ),
      setting_item(
        :banners,
        label: Banner.plural_label,
        href: BannerManagement.collection_iri
      ),
      setting_item(
        :vocabularies,
        label: Vocabulary.plural_label,
        href: Vocabulary.collection_iri(display: :table)
      ),
      setting_item(:delete, href: delete_iri(resource))
    ]
  end

  def setting_item_opts(tag, opts)
    {policy_resource: ActsAsTenant.current_tenant}.merge(super)
  end

  def sign_out_menu_item
    menu_item(
      :signout,
      action: NS.libro['actions/logout'],
      label: I18n.t('sign_out'),
      href: LinkedRails.iri(path: 'u/sign_out')
    )
  end

  def user_menu_items # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    [
      menu_item(
        :notifications,
        href: user_context.user.iri(fragment: :notifications),
        image: "fa-#{tab_icons[:notifications]}"
      ),
      menu_item(
        :drafts,
        href: user_context.user.iri(fragment: :drafts),
        image: "fa-#{tab_icons[:drafts]}"
      ),
      menu_item(
        :settings,
        href: user_context.user.iri(fragment: :settings),
        image: "fa-#{tab_icons[:settings]}"
      ),
      menu_item(
        :profile,
        href: user_context.user.iri,
        image: "fa-#{tab_icons[:profile]}"
      )
    ]
  end
end
