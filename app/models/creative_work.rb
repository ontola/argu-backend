# frozen_string_literal: true

class CreativeWork < Edge
  property :display_name, :string, NS::SCHEMA[:name]
  property :description, :text, NS::SCHEMA[:text]
  property :creative_work_type,
           :integer,
           NS::ARGU[:CreativeWorkType],
           default: 0,
           enum: {custom: 0, new_motion: 1, new_question: 2}

  class << self
    def iri
      NS::SCHEMA[:CreativeWork]
    end
  end
end
