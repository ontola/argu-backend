class RefactorGrants < ActiveRecord::Migration[5.1]
  def up
    enable_extension('intarray')
    add_column :grants, :grant_set_id, :integer

    create_table :grant_sets do |t|
      t.integer :page_id
      t.string :title
      t.index :title, unique: true
    end
    add_foreign_key :grants, :grant_sets

    create_table :permitted_actions do |t|
      t.string :title
      t.string :resource_type, null: false
      t.string :parent_type, null: false
      t.string :action, null: false
      t.boolean :trickles, null: false, default: true
      t.boolean :permit, null: false, default: true
      t.index :title, unique: true
    end

    create_table :grant_sets_permitted_actions do |t|
      t.integer :grant_set_id, null: false
      t.integer :permitted_action_id, null: false
    end
    add_foreign_key :grant_sets_permitted_actions, :grant_sets
    add_foreign_key :grant_sets_permitted_actions, :permitted_actions

    create_table :permitted_attributes do |t|
      t.integer :permitted_action_id, null: false
      t.string :name, null: false
    end
    add_foreign_key :permitted_attributes, :permitted_actions

    change_column :grants, :role, :integer, default: nil, null: true

    ENV['SEED'] = 'grant_sets'
    Rake::Task['db:seed:single'].invoke

    Grant.spectate.update_all(grant_set_id: GrantSet.find_by(title: 'spectator').id)
    Grant.participate.update_all(grant_set_id: GrantSet.find_by(title: 'initiator').id)
    Grant.administrate.update_all(grant_set_id: GrantSet.find_by(title: 'administrator').id)

    Edge.find_by(owner_type: 'Question', owner_id: 488)
  end

  def down
    disable_extension('intarray')
    remove_column :grants, :grant_set_id, :integer

    drop_table :grant_sets_permitted_actions
    drop_table :permitted_attributes
    drop_table :permitted_actions
    drop_table :grant_sets

    Grant.where(role: nil).destroy_all
    change_column :grants, :role, :integer, default: 0, null: false
  end
end
