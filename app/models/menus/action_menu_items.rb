# frozen_string_literal: true

module Menus
  module ActionMenuItems
    def comments_link
      menu_item(
        :comments,
        label_params: {count: resource.children_count(:comments)},
        image: 'fa-comments-o',
        href: polymorphic_url([resource, :comments]),
        policy: :index_children?,
        policy_arguments: %i[comments]
      )
    end

    def contact_link
      menu_item(
        :contact,
        image: 'fa-send-o',
        link_opts: {data: {remote: 'true'}},
        href: polymorphic_url([:new, resource, :direct_message]),
        policy: :contact?
      )
    end

    def activity_link
      menu_item(
        :activity,
        image: 'fa-feed',
        href: url_for([resource, :feed]),
        policy: :feed?
      )
    end

    def new_update_link
      menu_item(
        :new_update,
        image: 'fa-bullhorn',
        href: polymorphic_url([:new, resource, :blog_post]),
        policy: :create_child?,
        policy_arguments: %i[blog_posts]
      )
    end

    def edit_link
      menu_item(
        :edit,
        image: 'fa-edit',
        href: polymorphic_url([:edit, resource]),
        policy: :update?
      )
    end

    def statistics_link
      menu_item(
        :statistics,
        image: 'fa-bar-chart-o',
        href: edge_statistics_url(resource.edge),
        policy: :statistics?
      )
    end

    def trash_and_destroy_links
      resource.is_trashed? ? [untrash_link, destroy_link] : [trash_link, destroy_link]
    end

    def destroy_link
      menu_item(
        :destroy,
        href: polymorphic_url([:delete, resource]),
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
        href: polymorphic_url([:untrash, resource]),
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
        href: polymorphic_url([:trash, resource]),
        image: 'fa-trash',
        link_opts: {
          data: {remote: 'true'}
        },
        policy: :trash?
      )
    end
  end
end
