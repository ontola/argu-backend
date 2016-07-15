# frozen_string_literal: true
class Shortname < ActiveRecord::Base
  belongs_to :owner,
             polymorphic: true,
             required: true
  belongs_to :forum,
             inverse_of: :shortnames

  # Uniqueness is done in the database (since rails lowercase support sucks,
  # and this is a point where data consistency is critical)
  validates :shortname,
            presence: true,
            length: 3..50,
            uniqueness: true,
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

  SHORTNAME_FORMAT_REGEX = /\A[a-zA-Z]+[_a-zA-Z0-9]*\z/i

  def self.shortname_for(klass_name, id)
    Shortname.where(owner_type: klass_name, owner_id: id).pluck(:shortname).first
  end

  def self.shortnames_for_klass(klass_name, ids)
    Shortname.where(owner_type: klass_name, owner_id: ids).pluck(:shortname)
  end

  def self.shortname_owners_for_klass(klass_name, ids)
    Shortname.where(owner_type: klass_name, owner_id: ids).includes(:owner)
  end

  def self.find_resource(shortname)
    Shortname.find_by('lower(shortname) = lower(?)', shortname).try(:owner)
  end

  private

  def forum_id_matches_owner
    return if owner.is_a? Forum
    if forum.present? && owner.present? && forum != owner.forum
      errors.add(:owner, I18n.t('activerecord.errors.different_owner_forum'))
    end
  end
end
