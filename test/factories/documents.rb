# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    name { 'also_the_url' }
    title { 'title of the document' }
    contents { 'contents of the document' }

    factory :document_policy do
      name { 'policy' }
      title { 'Gebruiksvoorwaarden' }
      contents { '## Kernwaarden van Argu' }
    end
  end
end
