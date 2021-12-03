# frozen_string_literal: true

class VocabularyMenuList < ApplicationMenuList
  has_action_menu
  has_tabs_menu

  private

  def action_menu_items
    [
      copy_share_link(resource.iri),
      *trash_and_destroy_links(include_destroy: false)
    ]
  end

  def edit_form_link
    return if resource.custom_form.blank?

    menu_item(
      :edit_form,
      image: 'fa-edit',
      href: resource.custom_form.iri,
      policy: :update?
    )
  end

  def property_definitions_link
    menu_item(
      :property_definitions,
      image: 'fa-edit',
      href: resource.collection_iri(:property_definitions),
      policy: :update?
    )
  end

  def tabs_menu_items
    [
      terms_link,
      edit_link,
      property_definitions_link,
      edit_form_link
    ]
  end

  def terms_link
    menu_item(
      :terms,
      image: 'fa-list',
      href: resource.collection_iri(:terms)
    )
  end
end
