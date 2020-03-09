# frozen_string_literal: true

class FavoritesFeedController < FeedController
  private

  def authorize_action
    skip_verify_policy_authorized true
    raise Argu::Errors::Forbidden.new(query: :feed?) unless current_user.is_staff?
  end

  def controller_class
    Feed
  end

  def feed_resource
    current_user
  end

  def index_collection
    collection = super
    collection.instance_variable_set(
      :@iri,
      RDF::URI(DynamicUriHelper.rewrite(path_with_hostname('/staff/feed'), Page.argu))
    )
    collection
  end

  def parent_resource; end
end
