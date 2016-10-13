# frozen_string_literal: true
class Rule < ApplicationRecord
  # @todo remove this association and its columns after migration
  belongs_to :context, polymorphic: true
  belongs_to :branch, class_name: 'Edge'
  belongs_to :model, polymorphic: true
  enum trickles: {doesnt_trickle: 0, trickles_down: 1, trickles_up: 2}
end
