# frozen_string_literal: true

class GrantReset < ApplicationRecord
  belongs_to :edge, inverse_of: :grant_resets, primary_key: :uuid
  enum action_name: {
    create: 1,
    show: 2,
    update: 3,
    destroy: 4,
    trash: 5
  }, _prefix: true
  enum resource_type: {
    Forum: 1,
    BlogPost: 2,
    Question: 3,
    Motion: 4,
    ProArgument: 5,
    ConArgument: 6,
    Comment: 7,
    Vote: 8
  }, _prefix: true
end
