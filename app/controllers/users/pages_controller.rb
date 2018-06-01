# frozen_string_literal: true

module Users
  class PagesController < AuthorizedController
    skip_before_action :authorize_action, only: %i[index]

    private

    def index_respond_success_html
      render locals: {
        pages: index_response_association,
        current: current_user.edges.where(owner_type: 'Page').length,
        max: policy(current_user).max_allowed_pages
      }
    end

    def index_response_association
      @pages =
        policy_scope(Page)
          .where(
            id: user
                  .profile
                  .granted_record_ids(owner_type: 'Page')
                  .concat(user.edges.where(owner_type: 'Page').pluck(:owner_id))
          ).distinct
    end

    def user
      return @user if @user.present?
      @user = User.find_via_shortname! params[:id]
      authorize @user, :update?
      @user
    end
  end
end
