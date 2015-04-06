class Shortname < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  # Uniqueness is done in the database (since rails lowercase support sucks,
  # and this is a point where data consistency is critical)
  validates :shortname, presence: true, length: 3..50

  validates :shortname, exclusion: {in: IO.readlines('config/shortname_blacklist.lsv').map!(&:chomp)}
  validates_format_of :shortname, with: /\A[a-z]+[_a-z0-9]*\z/i, message: I18n.t('profiles.should_start_with_capital')

  SHORTNAME_FORMAT_REGEX = /\A[a-z]+[_a-z0-9]*\z/i


  def self.shortname_for(klass_name, id)
    Shortname.where(owner_type: klass_name, owner_id: id).pluck(:shortname).first
  end

  def self.shortnames_for_klass(klass_name, ids)
    Shortname.where(owner_type: klass_name, owner_id: ids).pluck(:shortname)
  end

end