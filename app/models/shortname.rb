# frozen_string_literal: true

class Shortname < ApplicationRecord # rubocop:disable Metrics/ClassLength
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable

  include Cacheable
  include Parentable

  belongs_to :owner,
             class_name: 'Edge',
             primary_key: :uuid,
             optional: false
  belongs_to :root,
             primary_key: :uuid,
             class_name: 'Edge'
  before_save :remove_primary_shortname, if: :primary?
  after_destroy :update_caches, if: :primary?
  after_save :update_caches, if: :primary?

  collection_options(
    display: :settingsTable
  )
  with_columns settings: [
    NS.argu[:alias],
    NS.argu[:shortnameable],
    NS.ontola[:destroyAction]
  ]

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
            allow_nil: true,
            format: {
              with: /\A[a-zA-Z]+[_a-zA-Z0-9]*\z/i,
              message: I18n.t('profiles.should_start_with_capital')
            }

  attr_accessor :destination

  SHORTNAME_FORMAT_REGEX = /\A[a-zA-Z]+[_a-zA-Z0-9]*\z/i.freeze

  def display_name; end

  def edgeable_record
    owner.root
  end

  def owner
    super || ActsAsTenant.current_tenant
  end

  def parent
    owner
  end

  def parent_collections(user_context)
    super + [self.class.root_collection(user_context: user_context)]
  end

  def path
    [base_path, shortname].join('/')
  end

  def url
    [base_url, shortname].join('/')
  end

  private

  def base_path
    root_id.present? ? "/#{root.url}" : ''
  end

  def base_url
    root_id.present? ? root.iri : RDF::DynamicURI(Rails.application.config.origin)
  end

  def remove_primary_shortname
    scope = owner.shortnames
    scope = scope.where.not(id: id) if id
    scope.update_all(primary: false) # rubocop:disable Rails/SkipsModelValidations
  end

  def update_caches
    return unless update_iris?

    new_path = owner.iri.path
    old_path = new_path.sub(*owner.url_change.reverse)

    Page.update_iris(old_path, new_path, root_id: root_id)
  end

  def update_iris?
    owner.url_changed? && owner.url_change.first && root_id
  end

  class << self
    def attributes_for_new(opts)
      {
        destination: opts[:parent]&.iri&.to_s&.split(LinkedRails.iri.to_s)&.last,
        primary: false,
        owner: opts[:parent] || ActsAsTenant.current_tenant,
        root: ActsAsTenant.current_tenant
      }
    end

    def find_resource(shortname, root_id = nil)
      Shortname.where(root_id: root_id).find_by('lower(shortname) = lower(?)', shortname).try(:owner)
    end

    def requested_index_resource(params, user_context)
      if params[:shortname]&.key?(:destination)
        collection_from_parent(
          index_collection_params(params, user_context)
            .merge(parent_iri: params.require(:shortname).require(:destination))
        )
      else
        super
      end
    end
  end
end
