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
        href: expand_uri_template(
          'new_iri',
          collection_iri: expand_uri_template(
            'direct_messages_collection_iri',
            parent_iri: resource.iri(only_path: true),
            only_path: true
          )
        ),
        policy: :contact?
      )
    end

    def activity_link
      menu_item(
        :activity,
        image: 'fa-feed',
        href: expand_uri_template('feed_iri', parent_iri: resource.iri(only_path: true)),
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
        href: expand_uri_template('edit_iri', parent_iri: resource.iri(only_path: true)),
        policy: :update?
      )
    end

    def export_link
      menu_item(
        :export,
        href: edge_exports_url(resource.edge),
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
        href: expand_uri_template('move_iri', parent_iri: resource.iri(only_path: true)),
        policy: :move?,
        link_opts: {
          data: {remote: 'true'}
        }
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
        href: expand_uri_template('delete_iri', parent_iri: resource.iri(only_path: true)),
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
        href: expand_uri_template('untrash_iri', parent_iri: resource.iri(only_path: true)),
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
        href: expand_uri_template('trash_iri', parent_iri: resource.iri(only_path: true)),
        image: 'fa-trash',
        link_opts: {
          data: {remote: 'true'}
        },
        policy: :trash?
      )
    end
  end
end
