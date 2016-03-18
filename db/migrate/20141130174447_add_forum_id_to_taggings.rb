class AddForumIdToTaggings < ActiveRecord::Migration
  def change
    add_column :taggings, :forum_id, :integer

    ActsAsTaggableOn::Tagging.all.each { |t| t.update_column(:taggable_type, 'Motion') if t.taggable_type == 'Statement' }
    ActsAsTaggableOn::Tagging.all.each { |t| puts t.taggable.present? ? t.taggable.display_name : t.destroy }
    ActsAsTaggableOn::Tagging.all.each { |t| @t = t; puts t.update_attribute :forum_id, t.taggable.read_attribute(:forum_id) }
  end
end
