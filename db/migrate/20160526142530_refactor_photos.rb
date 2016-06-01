class RefactorPhotos < ActiveRecord::Migration
  COVER_PHOTO_CLASSES = [Profile, Forum, Motion, Question]
  PROFILE_PHOTO_CLASSES = [Profile, Forum]

  def up
    change_column_null :photos, :forum_id, true
    change_column_null :photos, :used_as, false
    COVER_PHOTO_CLASSES.each do |klass|
      select_orphans(klass, Photo.used_as[:cover_photo])
        .find_each do |resource|
          resource
            .photos
            .cover_photo
            .create(photo_params(resource).merge(remote_image_url: cover_url(klass, resource)))
        end
    end

    PROFILE_PHOTO_CLASSES.each do |klass|
      select_orphans(klass, Photo.used_as[:profile_photo])
        .find_each do |resource|
          resource
            .photos
            .profile_photo
            .create(photo_params(resource).merge(remote_image_url: profile_url(klass, resource)))
        end
    end
  end

  def down
    Photo.delete_all
    change_column_null :photos, :forum_id, false
    change_column_null :photos, :used_as, true
  end

  def cover_url(klass, resource)
    "#{base_path}/#{klass.model_name.collection}/#{resource.id}/cover/#{resource.cover_photo}"
  end

  def profile_url(klass, resource)
    "#{base_path}/#{klass.model_name.collection}/#{resource.id}/avatar/#{resource.profile_photo}"
  end

  def base_path
    'https://argu-logos.s3.amazonaws.com'
  end

  def photo_params(resource)
    case resource
    when Profile
      if resource.profileable.is_a?(Page)
        {publisher: resource.profileable.owner.profileable, creator: resource, forum: nil}
      else
        {publisher: resource.profileable, creator: resource, forum: nil}
      end
    when Forum
      {publisher: resource.page.owner.profileable, creator: resource.page.owner, forum: resource}
    else
      {publisher: resource.publisher, creator: resource.creator, forum: resource.forum}
    end
  end

  def select_orphans(klass, type)
    klass.where(
      'id NOT IN (SELECT DISTINCT(about_id) FROM photos WHERE about_type = ? AND used_as = ?)',
      klass.to_s,
      type)
  end
end
