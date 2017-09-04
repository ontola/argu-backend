# frozen_string_literal: true

FactoryGirl.define do
  factory :rule do
    model_type nil
    model_id nil
    action nil
    role nil
    permit false
    trickles Rule.trickles[:trickles_down]
    branch nil
  end
end
