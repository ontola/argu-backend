# frozen_string_literal: true

class DraftsController < AuthorizedController
  private

  def authorize_action
    authorize user_by_id, :edit?
  end

  def index_collection
    @index_collection ||= ::Collection.new(
      collection_options.merge(
        association_class: Edge,
        association_scope: :draft,
        name: :drafts,
        parent: user_by_id,
        parent_uri_template: :drafts_collection_iri,
        parent_uri_template_canonical: :drafts_collection_canonical,
        policy: DraftPolicy,
        user_context: user_context
      )
    )
  end

  def collection_from_parent_name; end

  def user_by_id
    @user_by_id = User.find_via_shortname_or_id! params[:id]
  end

  def show_params
    params.permit(:page)
  end
end
