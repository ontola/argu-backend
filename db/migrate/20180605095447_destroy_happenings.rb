class DestroyHappenings < ActiveRecord::Migration[5.1]
  def change
    Activity.where("key ~ '*.happened'").destroy_all
  end
end
