class ActivityOwnerDefaultsToProfile < ActiveRecord::Migration
  def change
    change_column :activities, :owner_type, :string, default: 'Profile'

    activities = Activity.where("owner_type = '' OR owner_type IS NULL")
    batch_size = 1000
    0.step(activities.count, batch_size).each do |offset|
      activities.order(:id)
        .offset(offset)
        .limit(batch_size)
        .update_all(owner_type: 'Profile')
    end
  end
end
