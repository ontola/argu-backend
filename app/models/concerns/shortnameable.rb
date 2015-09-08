module Shortnameable
  extend ActiveSupport::Concern

  included do
    has_one :shortname, as: 'owner', dependent: :destroy
    accepts_nested_attributes_for :shortname
    after_initialize :build_shortname_if, if: :new_record?

    def build_shortname_if
      self.shortname ||= Shortname.new
    end

    def shortnameable?
      true
    end

    def to_param
      self.url.to_s.presence || id
    end

    def url
      Shortname.where(owner_id: self.id, owner_type: self.class.name).pluck(:shortname).first
    end
  end

  module ClassMethods
    # Finds an object via its shortname, throws an exception when not found
    def find_via_shortname(url)
      Rails.logger.info "+++++++++++++++++++#{url}+++++++++++++++++++"
      find_via_shortname_nil(url) or raise(ActiveRecord::RecordNotFound)
    end

    # Finds an object via its shortname, returns nil when not found
    def find_via_shortname_nil(url)
      self.where(id: Shortname
                         .where('lower(shortname) = lower(?)', url)
                         .where(owner_type: self.name)
                         .select(:owner_id)).first
    end

    # Finds an object via its shortname or id, throws an exception when not found
    def find_via_shortname!(url)
      if url.to_i.to_s == url.to_s
        self.find url.to_i
      else
        find_via_shortname_nil(url) or raise(ActiveRecord::RecordNotFound)
      end
    end

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

    def shortnameable?
      false
    end
  end
  ActiveRecord::Base.send(:include, ActiveRecordExtension)
end
