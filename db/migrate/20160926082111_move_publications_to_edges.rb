class MovePublicationsToEdges < ActiveRecord::Migration[5.0]
  def up
    change_column :publications, :publishable_type, :string, default: 'Edge'
    Publication.find_each do |publication|
      edge = publication.publishable_type.constantize.find(publication.publishable_id).edge
      publication.update(publishable_id: edge.id, publishable_type: 'Edge')
    end
  end

  def down
    change_column :publications, :publishable_type, :string, default: nil
    Publication.find_each do |publication|
      edge = Edge.find(publication.publishable_id)
      publication.update(publishable_id: edge.owner_id, publishable_type: edge.owner_type)
    end
  end
end
