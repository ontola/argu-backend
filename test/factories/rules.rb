FactoryGirl.define do
  factory :rule do
    model_type nil
    model_id nil
    action nil
    role nil
    permit false
    context_type nil
    context_id nil
    trickles Rule.trickles[:trickles_down]
  end
end
