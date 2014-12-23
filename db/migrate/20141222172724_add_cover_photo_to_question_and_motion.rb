class AddCoverPhotoToQuestionAndMotion < ActiveRecord::Migration
  def change
    add_column :questions, :cover_photo, :string, default: ''
    add_column :motions, :cover_photo, :string, default: ''
  end
end
