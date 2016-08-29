class Rule < ApplicationRecord
  belongs_to :context, polymorphic: true
  belongs_to :model, polymorphic: true
  enum trickles: {doesnt_trickle: 0, trickles_down: 1, trickles_up: 2}
end
