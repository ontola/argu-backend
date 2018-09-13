# frozen_string_literal: true

module Users
  class PagesController < AuthorizedController
    skip_before_action :authorize_action, only: %i[index]

    private

    def index_locals
      {
        pages: index_association,
        current: current_user.edges.where(owner_type: 'Page').length,
        max: policy(current_user).max_allowed_pages
      }
    end

    def index_association
      @pages =
        policy_scope(Page)
          .includes(:shortname, profile: %i[default_profile_photo default_cover_photo])
          .where(
            uuid: user
                  .profile
                  .granted_root_ids(%w[moderator administrator])
                  .concat(user.edges.where(owner_type: 'Page').pluck(:uuid))
          ).distinct
    end

    def index_collection
      @index_collection ||= current_user.managed_page_collection(collection_options)
    end

    def index_collection_name; end

    def user
      return @user if @user.present?
      @user = User.find_via_shortname! params[:id]
      authorize @user, :update?
      @user
    end
  end
end
