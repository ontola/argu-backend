# frozen_string_literal: true

class DraftsController < AuthorizedController
  private

  def authorize_action
    authorize user_by_id, :edit?
  end

  def index_collection
    @index_collection ||= ::Collection.new(
      association_class: Edge,
      association_scope: :draft,
      name: :drafts,
      parent: user_by_id,
      parent_uri_template: :drafts_collection_iri,
      parent_uri_template_canonical: :drafts_collection_canonical,
      policy: DraftPolicy,
      user_context: user_context
    )
  end

  def index_collection_name; end

  def index_success_html
    skip_verify_policy_scoped(true)

    blog_posts = BlogPost.where(creator_id: user_by_id.managed_profile_ids).unpublished.untrashed
    motions = Motion.where(creator_id: user_by_id.managed_profile_ids).unpublished.untrashed
    questions = Question.where(creator_id: user_by_id.managed_profile_ids).unpublished.untrashed
    @items = Kaminari
               .paginate_array((blog_posts + motions + questions)
                                 .sort_by(&:updated_at)
                                 .reverse)
               .page(show_params[:page])
               .per(30)
  end

  def user_by_id
    @user_by_id = User.find_via_shortname_or_id! params[:id]
  end

  def show_params
    params.permit(:page)
  end
end
