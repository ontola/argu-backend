module Shortnameable
  extend ActiveSupport::Concern

  included do
    has_one :shortname, as: 'owner'
    accepts_nested_attributes_for :shortname

    def url
      Shortname.where(owner_id: self.id, owner_type: self.class.name).pluck(:shortname).first
    end

    def to_param
      self.url.to_s
    end
  end

  module ClassMethods
    def find_via_shortname(url)
      model = self.arel_table
      shortname = Shortname.arel_table
      sql = model.join(shortname).on(shortname[:owner_id].eq(model[:id]).and(shortname[:owner_type].eq(self.name))).where(shortname[:shortname].eq(url)).project(model[Arel.star]).to_sql
      self.find_by_sql(sql).first or raise(ActiveRecord::RecordNotFound)
    end
  end
end
