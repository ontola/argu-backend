# frozen_string_literal: true

class AppMenuList < ApplicationMenuList
  include SettingsHelper
  include LanguageHelper

  has_menu :info,
           label: LinkedRails.translations(-> { I18n.t('about.info') }),
           image: 'fa-info',
           menus: -> { info_menu_items }
  has_menu :user,
           label: -> { resource.display_name },
           image: -> { resource.default_profile_photo.thumbnail },
           menus: -> { user_menu_items }

  def iri_opts
    {parent_iri: 'apex'}
  end

  def iri_template
    uri_template('menu_lists_iri')
  end

  private

  def info_menu_items
    [
      *custom_menu_items(:info, ActsAsTenant.current_tenant),
      powered_by_link
    ]
  end

  def powered_by_link
    return if ActsAsTenant.current_tenant.enable_white_label?

    menu_item(:powered_by, label: I18n.t('about.powered_by'), href: RDF::URI('https://ontola.io/nl/webdevelopment'))
  end

  def edit_profile_link
    "#{settings_user_users_url}#profile"
  end

  def language_menu_item
    menu_item(
      :language,
      label: I18n.t('set_language'),
      href: iri_from_template(:languages_iri)
    )
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

  def sign_out_menu_item
    menu_item(
      :signout,
      action: NS::ONTOLA['actions/logout'],
      label: I18n.t('sign_out'),
      href: RDF::DynamicURI(destroy_user_session_url)
    )
  end

  def user_base_items # rubocop:disable Metrics/AbcSize
    if resource.url.present?
      [
        menu_item(
          :show, label: I18n.t('show_type', type: I18n.t('users.type')), href: RDF::DynamicURI(user_url(user))
        ),
        menu_item(
          :profile, label: I18n.t('profiles.edit.title'), href: RDF::DynamicURI(edit_profile_link)
        )
      ]
    else
      [menu_item(:setup, label: I18n.t('profiles.setup.link'), href: RDF::DynamicURI(setup_users_url))]
    end
  end

  def user_forum_management_item
    menu_item(:forums, label: I18n.t('forums.management.title'), href: RDF::DynamicURI(forums_user_url(resource)))
  end

  def user_menu_items
    return [language_menu_item] if resource.guest?

    items = user_base_items
    items << user_settings_item
    items << user_pages_item if Apartment::Tenant.current == 'argu'
    items << language_menu_item
    items << sign_out_menu_item
    items
  end

  def user_pages_item
    menu_item(:pages, label: I18n.t('pages.my_pages'), href: RDF::DynamicURI(pages_user_url(resource)))
  end

  def user_settings_item
    menu_item(
      :settings,
      label: I18n.t('users.settings.title'),
      href: RDF::DynamicURI(settings_user_users_url)
    )
  end
end
