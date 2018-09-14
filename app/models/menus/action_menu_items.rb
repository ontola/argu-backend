# frozen_string_literal: true

module Menus
  module ActionMenuItems
    def comments_link
      menu_item(
        :comments,
        label_params: {count: resource.children_count(:comments)},
        image: 'fa-comments-o',
        href: collection_iri(resource, :comments),
        policy: :index_children?,
        policy_arguments: %i[comments]
      )
    end

    def contact_link
      menu_item(
        :contact,
        image: 'fa-send-o',
        link_opts: {data: {remote: 'true'}},
        href: new_iri(resource, :direct_messages),
        policy: :contact?
      )
    end

    def activity_link
      menu_item(
        :activity,
        image: 'fa-feed',
        href: feeds_iri(resource),
        policy: :feed?
      )
    end

    def new_update_link
      menu_item(
        :new_update,
        image: 'fa-bullhorn',
        href: new_iri(resource, :blog_posts),
        policy: :create_child?,
        policy_arguments: %i[blog_posts]
      )
    end

    def edit_link
      menu_item(
        :edit,
        image: 'fa-edit',
        href: edit_iri(resource),
        policy: :update?
      )
    end

    def export_link
      menu_item(
        :export,
        href: export_iri(resource),
        image: 'fa-cloud-download',
        link_opts: {data: {remote: 'true'}},
        policy: :create_child?,
        policy_arguments: [:exports]
      )
    end

    def move_link
      menu_item(
        :move,
        image: 'fa-sitemap',
        href: move_iri(resource),
        policy: :move?,
        link_opts: {
          data: {remote: 'true'}
        }
      )
    end

    def statistics_link
      return if afe_request?
      menu_item(
        :statistics,
        image: 'fa-bar-chart-o',
        href: statistics_iri(resource),
        policy: :statistics?
      )
    end

    def trash_and_destroy_links
      resource.is_trashed? ? [untrash_link, destroy_link] : [trash_link, destroy_link]
    end

    def destroy_link
      menu_item(
        :destroy,
        href: delete_iri(resource),
        image: 'fa-close',
        link_opts: {
          data: {remote: 'true'}
        },
        policy: :destroy?
      )
    end

    def untrash_link
      menu_item(
        :untrash,
        href: untrash_iri(resource),
        image: 'fa-eye',
        link_opts: {
          data: {remote: 'true'}
        },
        policy: :untrash?
      )
    end

    def trash_link
      menu_item(
        :trash,
        href: trash_iri(resource),
        image: 'fa-trash',
        link_opts: {
          data: {remote: 'true'}
        },
        policy: :trash?
      )
    end
  end
end
