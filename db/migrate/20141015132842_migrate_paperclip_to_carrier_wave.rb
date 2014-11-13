class MigratePaperclipToCarrierWave < ActiveRecord::Migration
  def change
    remove_columns :organisations, :profile_photo_file_name, :profile_photo_content_type, :profile_photo_file_size, :profile_photo_updated_at, :cover_photo_file_name, :cover_photo_content_type, :cover_photo_file_size, :cover_photo_updated_at

    remove_columns :groups, :profile_photo_file_name, :profile_photo_content_type, :profile_photo_file_size, :profile_photo_updated_at, :cover_photo_file_name, :cover_photo_content_type, :cover_photo_file_size, :cover_photo_updated_at

    remove_columns :profiles, :profile_photo_file_name, :profile_photo_content_type, :profile_photo_file_size, :profile_photo_updated_at, :cover_photo_file_name, :cover_photo_content_type, :cover_photo_file_size, :cover_photo_updated_at


    add_column :organisations, :profile_photo, :string
    add_column :organisations, :cover_photo, :string

    add_column :groups, :profile_photo, :string
    add_column :groups, :cover_photo, :string

    add_column :profiles, :profile_photo, :string
    add_column :profiles, :cover_photo, :string
  end
end
