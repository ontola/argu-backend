# frozen_string_literal: true

class Shortname < ApplicationRecord
  belongs_to :owner,
             polymorphic: true,
             primary_key: :uuid,
             required: true
  belongs_to :forum,
             inverse_of: :shortnames

  # Uniqueness is done in the database (since rails lowercase support sucks,
  # and this is a point where data consistency is critical)
  validates :shortname,
            presence: true,
            length: 3..50,
            uniqueness: {case_sensitive: false},
            allow_nil: true

  validates :shortname,
            exclusion: {in: IO.readlines('config/shortname_blacklist.lsv').map!(&:chomp)},
            if: :new_record?
  validates :shortname,
            format: {
              with: /\A[a-zA-Z]+[_a-zA-Z0-9]*\z/i,
              message: I18n.t('profiles.should_start_with_capital')
            }
  validate :forum_id_matches_owner

  after_create :destroy_finish_intro_notification

  SHORTNAME_FORMAT_REGEX = /\A[a-zA-Z]+[_a-zA-Z0-9]*\z/i

  def self.find_resource(shortname)
    Shortname.find_by('lower(shortname) = lower(?)', shortname).try(:owner)
  end

  private

  def destroy_finish_intro_notification
    owner.notifications.finish_intro.destroy_all if owner.is_a?(User)
  end

  def forum_id_matches_owner
    return if owner.is_a? Forum
    return unless forum.present? && owner.present? && forum.id != owner.parent_model(:forum).id
    errors.add(:owner, I18n.t('activerecord.errors.different_owner_forum'))
  end
end
