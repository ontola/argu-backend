# frozen_string_literal: true

class Shortname < ApplicationRecord
  enhance Actionable
  enhance Createable
  enhance Destroyable

  include Parentable

  belongs_to :owner,
             polymorphic: true,
             primary_key: :uuid,
             required: true
  belongs_to :root,
             primary_key: :uuid,
             class_name: 'Edge'
  before_save :remove_primary_shortname, if: :primary?
  after_save :cache_iri_path!, if: :primary?
  after_destroy :cache_iri_path!, if: :primary?

  # Uniqueness is done in the database (since rails lowercase support sucks,
  # and this is a point where data consistency is critical)
  validates :shortname,
            presence: true,
            length: 3..50,
            uniqueness: {case_sensitive: false, scope: :root_id},
            allow_nil: true
  validates :shortname,
            exclusion: {in: IO.readlines('config/shortname_blacklist.lsv').map!(&:chomp)},
            if: :new_record?,
            unless: :root_id
  validates :shortname,
            format: {
              with: /\A[a-zA-Z]+[_a-zA-Z0-9]*\z/i,
              message: I18n.t('profiles.should_start_with_capital')
            }

  after_create :destroy_finish_intro_notification
  attr_reader :destination

  SHORTNAME_FORMAT_REGEX = /\A[a-zA-Z]+[_a-zA-Z0-9]*\z/i

  def display_name; end

  def edgeable_record
    owner.is_a?(Edge) ? owner.root : owner
  end

  def self.find_resource(shortname, root_id = nil)
    Shortname.where(root_id: root_id).find_by('lower(shortname) = lower(?)', shortname).try(:owner)
  end

  def self.includes_for_serializer
    [owner: {}]
  end

  def parent
    owner
  end

  def path
    [base_path, shortname].join('/')
  end

  def url
    [base_url, shortname].join('/')
  end

  private

  def base_path
    root_id.present? ? root.iri_path : ''
  end

  def base_url
    root_id.present? ? root.iri : RDF::DynamicURI(Rails.application.config.origin)
  end

  def destroy_finish_intro_notification
    owner.notifications.finish_intro.destroy_all if owner.is_a?(User)
  end

  def remove_primary_shortname
    scope = owner.shortnames
    scope = scope.where('id != ?', id) if id
    scope.update_all(primary: false)
  end

  def cache_iri_path!
    owner.cache_iri_path!
  end
end
