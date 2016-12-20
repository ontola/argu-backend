class MovePublicationsToEdges < ActiveRecord::Migration[5.0]
  def up
    change_column :publications, :publishable_type, :string, default: 'Edge'
    Publication.find_each do |publication|
      edge = Edge.find_by(owner_type: publication.publishable_type, owner_id: publication.publishable_id)
      if edge.nil?
        publication.destroy!
      else
        publication.update_columns(publishable_id: edge.id, publishable_type: 'Edge')
      end
    end

    add_column :edges, :is_published, :boolean, default: false

    Edge.reset_column_information
    Edge.update_all(is_published: true)
    
    [Project, BlogPost, Decision].each do |klass|
      klass.joins(:edge).where(is_published: false, edges: {is_published: true}).find_each do |record|
        record.edge.update!(is_published: false)
      end
    end
  end
end
