class AddDefaultDecisionGroupToForums < ActiveRecord::Migration[5.1]
  def change
    Group.where(name: 'Admins', deletable: true).update_all(deletable: false)
    add_column :forums, :default_decision_group_id, :integer
    Forum.find_each do |forum|
      forum.send(:set_default_decision_group)
      forum.save!
    end
    change_column_null :forums, :default_decision_group_id, false
    add_foreign_key :forums, :groups, column: :default_decision_group_id
  end
end
