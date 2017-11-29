class RefactorGrants < ActiveRecord::Migration[5.1]
  def up
    add_column :grants, :grant_set_id, :integer

    create_table :grant_sets do |t|
      t.string :title
      t.integer :page_id
      t.index [:title, :page_id], unique: true
    end
    add_foreign_key :grant_sets, :pages
    add_foreign_key :grants, :grant_sets

    create_table :permitted_actions do |t|
      t.string :title
      t.string :resource_type, null: false
      t.string :parent_type, null: false
      t.string :action, null: false
      t.index :title, unique: true
    end

    create_table :grant_sets_permitted_actions do |t|
      t.integer :grant_set_id, null: false
      t.integer :permitted_action_id, null: false
    end
    add_foreign_key :grant_sets_permitted_actions, :grant_sets
    add_foreign_key :grant_sets_permitted_actions, :permitted_actions

    change_column :grants, :role, :integer, default: nil, null: true

    ENV['SEED'] = 'grant_sets'
    Rake::Task['db:seed:single'].invoke

    Grant.where(role: 0).update_all(grant_set_id: GrantSet.spectator.id)
    Grant.where(role: 1).update_all(grant_set_id: GrantSet.initiator.id)
    Grant.where(role: 10).update_all(grant_set_id: GrantSet.administrator.id)
    Grant.where(role: 100).update_all(grant_set_id: GrantSet.staff.id)
  end

  def down
    remove_column :grants, :grant_set_id, :integer

    drop_table :grant_sets_permitted_actions
    drop_table :permitted_actions
    drop_table :grant_sets

    Grant.where(role: nil).destroy_all
    change_column :grants, :role, :integer, default: 0, null: false
  end
end
