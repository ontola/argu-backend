# frozen_string_literal: true

module Users
  class PagesController < AuthorizedController
    skip_before_action :authorize_action, only: %i[index]

    private

    def index_locals
      {
        pages: index_association,
        current: current_user.page_count,
        max: policy(current_user).max_allowed_pages
      }
    end

    def index_association
      ActsAsTenant.without_tenant do
        @pages =
          policy_scope(Page)
            .includes(:shortname, profile: %i[default_profile_photo default_cover_photo])
            .where(
              uuid: user
                    .profile
                    .granted_root_ids(%w[moderator administrator])
                    .concat(user.page_ids)
            ).distinct
      end
    end

    def index_collection
      @collection ||= ::Collection.new(
        association_base: favorite_pages,
        association_class: Page,
        parent: current_user,
        user_context: user_context,
        title: t('pages.my_pages'),
        type: :paginated
      )
    end

    def favorite_pages
      return Page.none if user.guest?
      ActsAsTenant.without_tenant do
        page_ids =
          Forum.joins(:favorites, :parent).where(favorites: {user_id: current_user.id}).pluck('parents_edges.uuid')
        Kaminari.paginate_array(Page.where(uuid: page_ids).includes(:shortname, profile: :default_profile_photo).to_a)
      end
    end

    def user
      return @user if @user.present?
      @user = User.find_via_shortname! params[:id]
      authorize @user, :update?
      @user
    end
  end
end
