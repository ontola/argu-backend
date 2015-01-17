class AddIntroFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :finished_intro, :boolean, default: false
  end
end
