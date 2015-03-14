class AddFieldToForums < ActiveRecord::Migration
  def change
    add_column :forums, :signup_with_token?, :boolean, default: false
  end
end
