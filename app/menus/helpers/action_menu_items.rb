# frozen_string_literal: true

module Helpers
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
        policy_resource: resource.blog_post_collection(user_context: user_context)
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
        policy_resource: resource.export_collection(user_context: user_context)
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
        href: new_iri(Move.new(edge: resource).root_relative_iri),
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
        action: ontola_dialog_action(delete_iri(resource)),
        href: delete_iri(resource),
        image: 'fa-close',
        policy: :destroy?
      )
    end

    def untrash_link
      menu_item(
        :untrash,
        action: ontola_dialog_action(untrash_iri(resource)),
        href: untrash_iri(resource),
        image: 'fa-eye',
        policy: :untrash?
      )
    end

    def trash_link
      menu_item(
        :trash,
        action: ontola_dialog_action(trash_iri(resource)),
        href: trash_iri(resource),
        image: 'fa-trash',
        policy: :trash?
      )
    end
  end
end
