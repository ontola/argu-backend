class AddLastAcceptedToPagesAndUsers < ActiveRecord::Migration
  def up
    add_column :pages, :last_accepted, :datetime
    add_column :users, :last_accepted, :datetime

    User.update_all last_accepted: DateTime.now
    Page.update_all last_accepted: DateTime.now
  end

  def down
    remove_column :pages, :last_accepted
    remove_column :users, :last_accepted
  end
end
