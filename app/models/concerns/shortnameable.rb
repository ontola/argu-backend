# frozen_string_literal: true

module Shortnameable
  extend ActiveSupport::Concern

  included do
    extend UUIDHelper

    has_one :shortname,
            -> { where(primary: true) },
            as: 'owner',
            dependent: :destroy,
            inverse_of: :owner,
            autosave: true,
            primary_key: :uuid
    has_many :shortnames,
             as: 'owner',
             dependent: :destroy,
             inverse_of: :owner,
             primary_key: :uuid
    accepts_nested_attributes_for :shortname, :shortnames

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
      @url || shortname&.shortname
    end

    def url=(value)
      return if value == url
      shortname_root_id = is_a?(Page) || !is_a?(Edge) ? nil : root_id
      existing = Shortname.find_by(shortname: value, root_id: shortname_root_id)
      if existing&.primary?
        errors.add(:url, :taken)
        return
      end
      existing.primary = true if existing
      shortnames << (existing || Shortname.new(shortname: value, root_id: shortname_root_id))
      @url = value
    end
  end

  module ClassMethods
    # Finds an object via its shortname, throws an exception when not found
    # @raise [ActiveRecord::RecordNotFound] When the object wasn't found
    def find_via_shortname!(url, root_id = nil)
      find_via_shortname(url, root_id) || raise(ActiveRecord::RecordNotFound)
    end

    # Finds an object via its shortname, returns nil when not found
    def find_via_shortname(url, root_id = nil)
      if root_id && !uuid?(root_id)
        root_id = Page.find_via_shortname(root_id)&.uuid
        return if root_id.blank?
      end
      joins(:shortnames).where(shortnames: {root_id: root_id}).find_by('lower(shortname) = lower(?)', url)
    end

    # Finds an object via its shortname or id
    def find_via_shortname_or_id(url, root_id = nil)
      if (/[a-zA-Z]/i =~ url.to_s).nil?
        find_by(id: url)
      else
        find_via_shortname(url, root_id)
      end
    end

    # Finds an object via its shortname or id, throws an exception when not found
    # @raise [ActiveRecord::RecordNotFound] When the object wasn't found
    def find_via_shortname_or_id!(url, root_id = nil)
      find_via_shortname_or_id(url, root_id) || raise(ActiveRecord::RecordNotFound)
    end

    def includes_for_serializer
      super.merge(shortname: {})
    end

    # Useful to test whether a model is shortnameable
    def shortnameable?
      true
    end
  end

  module ActiveRecordExtension
    def self.included(base)
      base.class_eval do
        def self.shortnameable?
          false
        end
      end
    end

    # Useful to test whether a model is (not) shortnameable
    def shortnameable?
      false
    end
  end
  ActiveRecord::Base.send(:include, ActiveRecordExtension)
end
