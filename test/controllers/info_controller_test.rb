# frozen_string_literal: true
require 'test_helper'

class InfoControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  let(:team) do
    create(:setting,
           key: 'team',
           value: '{     "header": "Ons team",     "title": "Ons team",     "sections": [         {             "type"'\
           ': "image-wide",             "image": "team-argu.jpg"         },         {             "type": "double",   '\
           '          "fill": true,             "right": true,             "avatar": "team-joep-avatar.jpg",          '\
           '   "header": "Joep Meindertsma",             "body": ["CEO &amp; co-founder. Joep is verantwoordelijk voor'\
           ' het initiële concept, het ontwerp en de algemene bedrijfsvoering."],             "image": "team-joep.jpg"'\
           ',             "social": [                 {                     "icon": "linkedin",                     "u'\
           'rl": "http://nl.linkedin.com/in/jmeindertsma"                 },                 {                     "ic'\
           'on": "twitter",                     "url": "https://twitter.com/argu_joep"                 },             '\
           '    {                     "icon": "envelope",                     "url": "mailto:joep@argu.co"            '\
           '     }             ]         },         {             "type": "double",             "fill": false,        '\
           '     "right": false,             "avatar": "team-thom-avatar.jpg",             "header": "Thom van Kalkere'\
           'n",             "body": ["CTO &amp; co-founder. Thom is verantwoordelijk voor de techniek."],             '\
           '"image": "team-thom.jpg",             "social": [                 {                     "icon": "linkedin"'\
           ',                     "url": "http://nl.linkedin.com/in/fletcher91"                 },                 {  '\
           '                   "icon": "twitter",                     "url": "https://twitter.com/fletcher91"         '\
           '        },                 {                     "icon": "envelope",                     "url": "mailto:th'\
           'om@argu.co"                 }             ]         },         {             "type": "double",            '\
           ' "fill": true,             "right": true,             "avatar": "team-michiel-avatar.jpg",             "he'\
           'ader": "Michiel van den Ingh",             "body": ["CFO &amp; co-founder. Michiel is verantwoordelijk voo'\
           'r de sales en marketing."],             "image": "team-michiel.jpg",             "social": [              '\
           '   {                     "icon": "linkedin",                     "url": "https://www.linkedin.com/profile/'\
           'view?id=132896278"                 },                 {                     "icon": "twitter",            '\
           '         "url": "https://twitter.com/mjvandeningh"                 },                 {                   '\
           '  "icon": "envelope",                     "url": "mailto:michiel@argu.co"                 }             ] '\
           '        },         {             "type": "single",             "fill": false,             "header": "Raad '\
           'van advies",             "people": [                 {                     "avatar": "advisors-steven.jpg"'\
           ',                     "name": "Steven Kraal",                     "function": "eigenaar van Like No Other"'\
           ',                     "quote": "Het team van Argu laat zien dat ze de visie, enorm doorzettingsvermogen &a'\
           'mp; creativiteit hebben om politieke besluitvormingsprocessen opener, democratischer en leuker te maken." '\
           '                },                 {                     "avatar": "advisors-rutger.jpg",                 '\
           '    "name": "Rutger Beumer",                     "function": "directeur van SiteWorkers",                 '\
           '    "quote": "Argu zet een goede stap richting gestructureerde online discussie, afgedwongen door slimme t'\
           'echniek. Een ambitieus team met de ware startup mentaliteit."                 },                 {        '\
           '             "avatar": "advisors-hedzer.jpg",                     "name": "Hedzer Kooistra",              '\
           '       "function": "strateeg bij gemeente Oegstgeest",                     "quote": "Het vergt zowel moed '\
           'als leiderschap om als overheid de kracht van de samenleving te benutten voor besluitvorming. Argu kan daa'\
           'rbij ondersteunen."                 },                 {                     "avatar": "advisors-duke.jpg"'\
           ',                     "name": "Duke Urbanik",                     "function": "Strategie coach, co-founder'\
           ' van the Venture Generator"                 }             ]         },         {             "type": "sing'\
           'le",             "fill": true,             "id": "vacatures",             "header": "Werken bij Argu",    '\
           '         "body": ["Wij zoeken altijd op zoek naar talent. Lijkt het jou leuk om bij ons team mee te bouwen'\
           ' aan de toekomst van online discussies?"],             "link": {                 "body": "Betaalde stage ('\
           'web)ontwikkelaar",                 "url": "https://argu.co/i/vacature_stage"             }         },     '\
           '    {             "type": "single",             "fill": false,             "id": "wijbedanken",           '\
           '  "header": "Wij bedanken",             "partners": [                 {                     "name": "Utrec'\
           'htInc",                     "url": "http://utrechtinc.nl/",                     "image": "partners-utrecht'\
           'inc.png"                 },                 {                     "name": "Democratic Challenge - MinBZK",'\
           '                     "url": "http://www.democraticchallenge.nl",                     "image": "partners-de'\
           'mocratic-challenge.png"                 },                 {                     "name": "Ministerie van B'\
           'innenlandse Zaken",                     "url": "http://www.rijksoverheid.nl/ministeries/bzk",             '\
           '        "image": "partners-bzk.jpg"                 },                 {                     "name": "Expe'\
           'rtisepunt Open Overheid",                     "url": "http://open-overheid.nl/",                     "imag'\
           'e": "partners-open-overheid.jpg"                 },                 {                     "name": "Open Go'\
           'vernment Partnership",                     "url": "http://www.opengovpartnership.org/",                   '\
           '  "image": "partners-ogp.png"                 },                 {                     "name": "Open State'\
           ' Foundation",                     "url": "http://www.openstate.eu/nl",                     "image": "partn'\
           'ers-osf.png"                 },                 {                     "name": "Rabobank Pre-Seed Fund",   '\
           '                  "url": "http://rabopreseedfund.nl/",                     "image": "partners-rabobank.png'\
           '"                 },                 {                     "name": "Netwerk Democratie",                  '\
           '   "url": "http://netdem.nl/",                     "image": "partners-netdem.gif"                 },      '\
           '           {                     "name": "Pakhuis de Zwijger",                     "url": "https://dezwijg'\
           'er.nl/",                     "image": "partners-pakhuis-de-zwijger.jpg"                 },                '\
           ' {                     "name": "Gemeente Utrecht",                     "url": "http://utrecht.nl/",       '\
           '              "image": "partners-utrecht.png"                 },                 {                     "na'\
           'me": "Gemeente Houten",                     "url": "http://houten.nl/",                     "image": "part'\
           'ners-houten.jpg"                 }             ]         }     ] }')
  end
  let(:quotes) do
    create(:setting,
           key: '',
           value: 'Argumenten moet men wegen, niet tellen.;Beledigingen zijn de argumenten van hen die ongelijk hebben'\
           '.;Vooroordelen zijn de argumenten van dwazen.;Goede argumenten moeten voor betere wijken.')
  end

  ####################################
  # Not logged in
  ####################################
  test 'should get show when not logged in' do
    get :show, params: {id: team.key}

    assert_response 200
    assert assigns(:document)
    assert_equal 'image-wide', assigns(:document)['sections'].first['type']
  end

  test 'should 404 for get nonexistent when not logged in' do
    get :show, params: {id: 'does_not_exist'}

    assert_response 404
    assert_not assigns(:document)
  end

  test 'should 404 for non-json setting when not logged in' do
    get :show, params: {id: quotes.key}

    assert_response 404
    assert_not assigns(:document)
  end

  test 'should 404 for non-info setting when not logged in' do
    get :show, params: {id: 'user_cap'}

    assert_response 404
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'should get show' do
    sign_in user

    get :show, params: {id: team.key}

    assert_response 200
    assert assigns(:document)
    assert_equal 'image-wide', assigns(:document)['sections'].first['type']
  end

  test 'should 404 for get nonexistent' do
    sign_in user

    get :show, params: {id: 'does_not_exist'}

    assert_response 404
    assert_not assigns(:document)
  end

  test 'should 404 for non-json setting' do
    sign_in user

    get :show, params: {id: quotes.key}

    assert_response 404
    assert_not assigns(:document)
  end

  test 'should 404 for non-info setting' do
    sign_in user

    get :show, params: {id: 'user_cap'}

    assert_response 404
  end
end
