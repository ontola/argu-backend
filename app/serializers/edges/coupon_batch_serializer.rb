# frozen_string_literal: true

class CouponBatchSerializer < EdgeSerializer
  attribute :display_name, predicate: NS.schema.name do |object|
    object.display_name || I18n.t('argu.CouponBatch.plural_label')
  end
end
