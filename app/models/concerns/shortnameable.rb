# frozen_string_literal: true

module Shortnameable
  extend ActiveSupport::Concern

  included do
    has_one :shortname,
            as: 'owner',
            dependent: :destroy,
            inverse_of: :owner,
            autosave: true,
            primary_key: :uuid
    accepts_nested_attributes_for :shortname
    after_initialize :build_shortname_if, if: :build_shortname?

    def build_shortname?
      new_record? && shortnameable?
    end

    def build_shortname_if
      self.shortname ||= Shortname.new
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
      shortname&.shortname
    end
  end

  module ClassMethods
    # Finds an object via its shortname, throws an exception when not found
    # @raise [ActiveRecord::RecordNotFound] When the object wasn't found
    def find_via_shortname!(url)
      find_via_shortname(url) || raise(ActiveRecord::RecordNotFound)
    end

    # Finds an object via its shortname, returns nil when not found
    def find_via_shortname(url)
      joins(:shortname).find_by('lower(shortname) = lower(?)', url)
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
