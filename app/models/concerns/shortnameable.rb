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
    def find_via_shortname(url)
      self.joins(:shortname).where('lower(shortname) = lower(?)', url).first or raise(ActiveRecord::RecordNotFound)
    end

    def find_via_shortname!(url)
      if url.to_i.to_s == url.to_s
        self.find url.to_i
      else
        self.joins(:shortname).where('lower(shortname) = lower(?)', url).first or raise(ActiveRecord::RecordNotFound)
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
