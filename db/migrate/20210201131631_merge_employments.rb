class MergeEmployments < ActiveRecord::Migration[6.0]
  def change
    Property.where(predicate: NS::RIVM[:employmentId].to_s).pluck(:edge_id, :linked_edge_id).each do |edge_id, employment_id|
      Property.where(edge_id: employment_id).find_each do |property|
        Property.create!(
          edge_id: edge_id,
          created_at: property.created_at,
          updated_at: property.updated_at,
          predicate: property.predicate,
          boolean: property.boolean,
          string: property.string,
          text: property.text,
          datetime: property.datetime,
          integer: property.integer,
          linked_edge_id: property.linked_edge_id,
          order: property.order,
          iri: property.iri,
          language: property.language,
          root_id: property.root_id,
        )
      end
    end
  end
end
