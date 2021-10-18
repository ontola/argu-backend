class MakeDiscussionWidgetsInfinite < ActiveRecord::Migration[5.2]
  include UriTemplateHelper

  def change
    Widget.discussions.includes(:owner).each do |w|
      w.update(resource_iri: collection_iri(w.owner, Discussion.route_key, type: :infinite))
    end
  end
end
