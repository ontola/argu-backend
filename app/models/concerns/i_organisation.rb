module IOrganisation
  extend ActiveSupport::Concern

  included do
    has_many :statements

    enum public_form: { f_public: 0, f_private: 1, f_hidden: 2 }
    enum application_form: { f_open: 0, f_request: 1, f_invite: 2, f_management_invite: 3 }

    mount_uploader :profile_photo, ImageUploader
    mount_uploader :cover_photo, ImageUploader
  end



  ######Attributes#######
  def key_tags
    (super || '').split(',').map &:strip
  end

  def key_tags_raw
    self.attribute :key_tags
  end

  module ClassMethods

  end
end
