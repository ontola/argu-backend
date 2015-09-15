class AddFkMotionArguments < ActiveRecord::Migration
  def up
    add_foreign_key :arguments, :motions, delete: :cascade
  end

  def down
    remove_foreign_key :argument, :motion
  end
end
