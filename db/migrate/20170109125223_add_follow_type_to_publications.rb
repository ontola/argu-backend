class AddFollowTypeToPublications < ActiveRecord::Migration[5.0]
  def change
    add_column :publications, :follow_type, :integer, null: false, default: Publication.follow_types[:reactions]
    Decision.where('state != ?', Decision.states[:forwarded]).find_each do |record|
      record.argu_publication.update!(follow_type: Publication.follow_types[:news])
    end
    BlogPost.find_each do |record|
      record.argu_publication.update!(follow_type: Publication.follow_types[:news])
    end
  end
end
