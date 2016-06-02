FactoryGirl.define do
  factory :edge do
    association :user
    fragment { owner.identifier }
    parent do
      passed_in?(:parent) ? parent : owner.parent.edge
    end
    parent_fragment { parent.owner.identifier }
    path { [parent_fragment, fragment].join('.') }

    after :build do |edge|
      p_edge = edge.owner.parent.edge
      if edge.parent != p_edge
        edge.parent = p_edge
        edge.parent_fragment = p_edge.owner.identifier
      end
      edge.path = [p_edge.fragment, edge.fragment].compact.join('.') if edge.path.blank?
    end
  end
end
