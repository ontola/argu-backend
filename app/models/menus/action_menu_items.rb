# frozen_string_literal: true

module Menus
  module ActionMenuItems
    def contact_link
      menu_item(
        :contact,
        image: 'fa-send-o',
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

    def search_link
      menu_item(
        :search,
        image: 'fa-search',
        href: search_results_iri(resource),
        policy: :show?
      )
    end

    def new_update_link
      menu_item(
        :new_update,
        image: 'fa-bullhorn',
        href: new_iri(resource, :blog_posts),
        policy: :create_child?,
        policy_arguments: [BlogPost]
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
        href: collection_iri(resource, :exports),
        image: 'fa-cloud-download',
        policy: :create_child?,
        policy_arguments: [Export]
      )
    end

    def convert_link
      menu_item(
        :convert,
        image: 'fa-retweet',
        href: new_iri(resource, :conversions),
        policy: :convert?
      )
    end

    def move_link
      menu_item(
        :move,
        image: 'fa-sitemap',
        href: new_iri(Move.new(edge: resource).iri_path),
        policy: :move?
      )
    end

    def statistics_link
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
        policy: :destroy?
      )
    end

    def untrash_link
      menu_item(
        :untrash,
        href: untrash_iri(resource),
        image: 'fa-eye',
        policy: :untrash?
      )
    end

    def trash_link
      menu_item(
        :trash,
        href: trash_iri(resource),
        image: 'fa-trash',
        policy: :trash?
      )
    end
  end
end
