# frozen_string_literal: true

module Shortnameable
  extend ActiveSupport::Concern

  included do
    extend UUIDHelper

    has_one :shortname,
            -> { where(primary: true) },
            dependent: :destroy,
            foreign_key: :owner_id,
            inverse_of: :owner,
            autosave: true,
            primary_key: :uuid
    has_many :shortnames,
             dependent: :destroy,
             foreign_key: :owner_id,
             inverse_of: :owner,
             primary_key: :uuid
    accepts_nested_attributes_for :shortname, :shortnames
    validates :url,
              allow_blank: true,
              format: {
                with: Shortname
                        .validators
                        .detect { |validator| validator.is_a?(ActiveModel::Validations::FormatValidator) }
                        .options[:with],
                message: ->(_date_or_time, **_options) { I18n.t('profiles.should_start_with_capital') }
              }

    validate :validate_no_duplicate_shortname

    attribute :url, :string

    with_collection :shortnames
  end

  # Useful to test whether a model is shortnameable
  def shortnameable?
    true
  end

  # Makes sure that when included on models, the rails path helpers etc. use the object's shortname.
  # If it hasn't got a shortname, it will fall back to its id.
  # @return [String, Integer] The shortname of the model, or its id if not present.
  def to_param
    url.to_s.presence || id
  end

  # @return [String, nil] The shortname of the model or nil
  def url
    return preloaded_url if attributes.key?('preloaded_url')

    if super.nil? && shortname && !shortname.destroyed?
      current_url = shortname.shortname
      self[:url] = current_url
      clear_attribute_changes(%i[url])
    end

    super
  end

  def url=(value)
    return if value == url

    super

    new_shortname = shortname_for_url(value)
    shortnames << new_shortname if new_shortname
  end

  private

  def shortname_for_url(value) # rubocop:disable Metrics/CyclomaticComplexity
    return if value.blank?

    shortname_root_id = is_a?(Page) || !is_a?(Edge) ? nil : root_id
    existing = Shortname.find_by(shortname: value, root_id: shortname_root_id)
    if existing&.primary?
      @duplicate_shortname = true
      return
    end
    existing.primary = true if existing
    (existing || Shortname.new(shortname: value, root_id: shortname_root_id))
  end

  def validate_no_duplicate_shortname
    errors.add(:url, :taken) if @duplicate_shortname
  end

  module ClassMethods
    # Finds an object via its shortname, throws an exception when not found
    # @raise [ActiveRecord::RecordNotFound] When the object wasn't found
    def find_via_shortname!(url)
      find_via_shortname(url) || raise(ActiveRecord::RecordNotFound)
    end

    # Finds an object via its shortname, returns nil when not found
    def find_via_shortname(url)
      joins(:shortnames).find_by('lower(shortname) = lower(?)', url)
    end

    # Finds an object via its shortname or id
    def find_via_shortname_or_id(url)
      if (/[a-zA-Z]/i =~ url.to_s).nil?
        find_by(id: url)
      else
        find_via_shortname(url)
      end
    end

    # Finds an object via its shortname or id, throws an exception when not found
    # @raise [ActiveRecord::RecordNotFound] When the object wasn't found
    def find_via_shortname_or_id!(url)
      find_via_shortname_or_id(url) || raise(ActiveRecord::RecordNotFound)
    end

    def includes_for_serializer
      super.merge(shortname: {})
    end

    def requested_single_resource(params, _user_context)
      url = params[:id]

      return super unless (/[a-zA-Z]/i =~ url).present? && !uuid?(url)

      Shortname.find_resource(url, ActsAsTenant.current_tenant&.uuid) ||
        Shortname.find_resource(url)
    end

    # Useful to test whether a model is shortnameable
    def shortnameable?
      true
    end
  end

  module ActiveRecordExtension
    extend ActiveSupport::Concern

    module ClassMethods
      def shortnameable?
        false
      end
    end

    # Useful to test whether a model is (not) shortnameable
    def shortnameable?
      false
    end
  end
  ActiveRecord::Base.include ActiveRecordExtension
end
