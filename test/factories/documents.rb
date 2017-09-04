# frozen_string_literal: true

FactoryGirl.define do
  factory :document do
    name 'also_the_url'
    title 'title of the document'
    contents 'contents of the document'

    factory :document_policy do
      name 'policy'
      title 'Gebruiksvoorwaarden'
      contents '## Kernwaarden van Argu

             Argu is gemaakt met een aantal kernwaarden in gedachten. Deze kernwaarden zijn versmolten in het DNA van'\
             ' Argu. Waar mogelijk zetten we ons in om deze waarden te verspreiden en de doelen mogelijk te maken.



             1. **Individuele vrijheid**<br />Het individu en haar persoonlijke vrijheid is de beste maatstaf om leed'\
             ' te minimaliseren. Argu ziet een betere toekomst, zonder dwang, door vrijheid van het individu centraal'\
             ' te stellen. '
    end
  end
end
