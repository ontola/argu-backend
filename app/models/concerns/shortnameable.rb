module Shortnameable
  extend ActiveSupport::Concern

  included do
    has_one :shortname, as: 'owner'
    accepts_nested_attributes_for :shortname
    after_initialize :build_shortname_if, if: :new_record?

    def url
      Shortname.where(owner_id: self.id, owner_type: self.class.name).pluck(:shortname).first
    end

    def to_param
      self.url.to_s
    end

    def build_shortname_if
      self.shortname ||= Shortname.new
    end
  end

  module ClassMethods
    def find_via_shortname(url)
      self.joins(:shortname).where('lower(shortname) = lower(?)', url).first or raise(ActiveRecord::RecordNotFound)
    end
  end
end
