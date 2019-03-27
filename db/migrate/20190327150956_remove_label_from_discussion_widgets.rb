class RemoveLabelFromDiscussionWidgets < ActiveRecord::Migration[5.2]
  def change
    Widget.discussions.find_each { |a| a.update(resource_iri: [a.resource_iri.last]) }
  end
end
