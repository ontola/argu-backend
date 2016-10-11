# frozen_string_literal: true
require 'test_helper'

class DocumentsTest < ActionDispatch::IntegrationTest
  let!(:policy) do
    create(:document,
           name: 'policy',
           title: 'Gebruiksvoorwaarden',
           contents: '## Kernwaarden van Argu

             Argu is gemaakt met een aantal kernwaarden in gedachten. Deze kernwaarden zijn versmolten in het DNA van'\
             ' Argu. Waar mogelijk zetten we ons in om deze waarden te verspreiden en de doelen mogelijk te maken.



             1. **Individuele vrijheid**<br />Het individu en haar persoonlijke vrijheid is de beste maatstaf om leed'\
             ' te minimaliseren. Argu ziet een betere toekomst, zonder dwang, door vrijheid van het individu centraal'\
             ' te stellen. ')
  end
  let!(:privacy) do
    create(:document,
           name: 'privacy',
           title: 'Privacy Policy',
           contents: '##Algemeen
             Dit is de Privacy Policy van Argu. Wij zijn verantwoordelijk voor het verwerken van persoonsgegevens van'\
             ' onze Gebruikers. In deze Privacy Policy wordt beschreven hoe deze gegevensverwerking geschiedt en voor'\
             ' welke doeleinden deze gegevens worden verwerkt.
             Door onze Website te gebruiken, gaat u akkoord met de volgende voorwaarden die daarop van toepassing '\
             'zijn. Indien u niet met deze Privacy Policy akkoord gaat, wordt u verzocht de Website niet te gebruiken'\
             ' en dit aan ons te melden.

             ##Definities
             In deze Privacy Policy hebben de navolgende begrippen de volgende betekenis:
             - Gebruiker: iedere gebruiker van de Website.
             - Privacy Policy: deze Privacy Policy van Argu.')
  end
  let!(:cookies) do
    create(:document,
           name: 'cookies',
           title: 'Cookiebeleid',
           contents: 'lorem ipsum et dolorum est')
  end
  let!(:values) do
    create(:document,
           name: 'values',
           title: 'Kernwaarden',
           contents: 'lorem ipsum et dolorum est')
  end

  test 'should get policy' do
    get '/policy'
    assert_response :success
  end

  test 'should get privacy' do
    get '/privacy'
    assert_response :success
  end

  test 'should get cookies' do
    get '/cookies'
    assert_response :success
  end

  test 'should get values' do
    get '/values'
    assert_response :success
  end
end
