# frozen_string_literal: true

module DataCube
  class Component < LinkedRails::Resource
    attr_accessor :data_set, :order, :predicate

    def description
      I18n.t("statistics.#{key}.tooltip", default: nil)
    end

    def key
      @key ||= predicate.to_s.gsub(NS.argu.to_s, '').underscore
    end

    def label
      I18n.t("statistics.#{key}.label", default: nil)
    end
  end
end
