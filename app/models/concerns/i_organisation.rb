module IOrganisation
  extend ActiveSupport::Concern

  included do
    has_many :statements

    enum public_form: { f_public: 0, f_private: 1, f_hidden: 2 }
    enum application_form: { f_open: 0, f_request: 1, f_invite: 2, f_management_invite: 3 }

    has_attached_file :profile_photo
    validates_attachment_content_type :profile_photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/webm"]
    has_attached_file :cover_photo, styles: { :cropped => '1500' }
    validates_attachment_content_type :cover_photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/webm"]
    crop_attached_file :cover_photo, :aspect => "15:4"
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
