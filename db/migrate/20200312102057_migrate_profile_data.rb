class MigrateProfileData < ActiveRecord::Migration[6.0]
  def change
    # drop unused columns
    remove_column :profiles, :slug
    remove_column :profiles, :profile_photo
    remove_column :profiles, :cover_photo
    remove_column :profiles, :attachments_count

    # migrate to users
    {is_public: :boolean, are_votes_public: :boolean, about: :text}.each do |column, type|
      add_column :users, column, type, default: type == :boolean ? true : ''
      User.connection.update("UPDATE users SET #{column} = profiles.#{column} FROM profiles WHERE users.uuid = profiles.profileable_id")
    end
    rename_column :users, :are_votes_public, :show_feed

    # migrate to pages
    Property.create(
      Profile.where(profileable_type: 'Edge').pluck(:profileable_id, :name).map do |props|
        {edge_id: props.first, string: props.second, predicate: NS.schema.name.to_s}
      end
    )

    # move media_objects to profileables
    MediaObject.connection.update(
      'UPDATE media_objects SET about_type = profiles.profileable_type, about_id = profiles.profileable_id FROM profiles '\
      "WHERE media_objects.about_type = 'Profile' AND media_objects.about_id = profiles.uuid AND "\
      "media_objects.used_as IN (1, 2)"
    )

    # remove votes by organizations
    scope = Vote.joins(:creator).where(profiles: {profileable_type: 'Edge'})
    raise 'Deleting too many votes' if scope.count > 20
    scope.destroy_all

    # remove votes by organizations
    scope = Activity.joins('LEFT JOIN "profiles" ON "profiles"."id" = "activities"."owner_id"').where('profiles.id IS NULL')
    raise 'Deleting too many activities' if scope.count > 30
    scope.destroy_all
  end
end
