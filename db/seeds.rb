# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

u1 = User
       .new(
         id: User::COMMUNITY_ID,
         shortname: Shortname.new(shortname: 'community'),
         email: 'community@argu.co',
         password: '11a57b48a5810f09bf7d893174657959df7ecd6d4a055d66',
         finished_intro: true
       )
u1.build_profile(id: Profile::COMMUNITY_ID, profileable: u1)
u1.save!
u1.update(encrypted_password: '')

argu = Page
         .new(
           owner: User.find_via_shortname!('community').profile,
           shortname_attributes: {shortname: 'argu'},
           last_accepted: Time.current
         )
argu.build_profile(name: 'Argu', profileable: argu)
argu.edge = Edge.new(owner: argu, user: argu.publisher)
argu.save!
argu.edge.publish!

public_group = Group.new(
  id: Group::PUBLIC_ID,
  name: 'Public',
  page: argu
)
public_group.save!

staff_group = Group.new(
  id: Group::STAFF_ID,
  name: 'Staff',
  page: argu
)
staff_group.save!

staff = User
  .create!(
    email: 'staff@argu.co',
    shortname_attributes: {shortname: 'staff_account'},
    password: 'arguargu',
    password_confirmation: 'arguargu',
    first_name: 'Douglas',
    last_name: 'Engelbart',
    finished_intro: true,
    profile: Profile.new
  )
CreateGroupMembership.new(
  staff_group,
  attributes: {member: staff.profile},
  options: {publisher: staff, creator: staff.profile}
).commit
argu.update(owner: staff.profile)

forum = Forum.new(name: 'Nederland',
                  page: argu,
                  public_grant: 'member',
                  shortname_attributes: {shortname: 'nederland'})
forum.edge = Edge.new(owner: forum,
                      user: User.find_via_shortname!('staff_account'),
                      parent: argu.edge)
forum.edge.grants.new(group: public_group, role: :member)
forum.save!
forum.edge.publish!

Doorkeeper::Application.create!(
  id: Doorkeeper::Application::ARGU_ID,
  name: 'Argu',
  owner: u1.profile,
  redirect_uri: 'https://argu.co/'
)

Setting.set('quotes', 'Argumenten moet men wegen, niet tellen.')

Setting.set('about',
            '{     "header": "Over onze visie",     "sections": [         {             "type": "single",             '\
            '"fill": false,             "slogan": true,             "body": [                 "Argu is een online disc'\
            'ussieplatform voor ieder die mee wil denken over het oplossen van problemen. Argu maakt discussies overzi'\
            'chtelijk door uitdagingen, voorstellen en argumenten centraal te stellen."                 ]         },  '\
            '       {             "type": "double",             "fill": true,             "right": true,             "'\
            'header": "Politiek moet inhoudelijker",             "body": ["Politieke discussies moeten gaan over het o'\
            'plossen van problemen; niet over TV-optredens en one-liners."],             "image": "bg-landing-hong-kon'\
            'g.jpg",             "expand": {                 "id": "inhoudelijker",                 "header": "Politie'\
            'k moet inhoudelijker",                 "body": [                     "Politiek bestaat te veel uit market'\
            'ing en te weinig uit zinvolle, oplossingsgerichte discussies. Dat is zonde, want politieke beslissingen g'\
            'aan ons allemaal aan. Leven in een democratie betekent meer dan eens in de zoveel jaar naar een stemhokje'\
            ' gaan; het betekent dat wij allemaal mee kunnen denken over hoe we onze grootste problemen gaan oplossen.'\
            '",                     "Internet heeft veranderd hoe we met elkaar communiceren, hoe we leren en hoe we o'\
            'ns ontwikkelen. Social media heeft meer mensen een stem gegeven, maar heeft nog niet de inhoud en diepgan'\
            'g kunnen bieden die nodig is voor inhoudelijke discussies. Discussies over lastige onderwerpen passen nie'\
            't in 140 karakters. Democratie heeft een modern platform nodig."                 ]             }         '\
            '},         {             "type": "double",             "fill": false,             "right": false,        '\
            '     "header": "Gestructureerde discussies",             "body": ["Discussies op internet kunnen veel bet'\
            'er. Argu introduceert een unieke structuur om discussies overzichtelijk en oplossingsgericht te houden."]'\
            ',             "image": "bg-landing-stemmen.jpg",             "expand": {                 "id": "discussie'\
            's",                 "header": "Tijd voor goede online discussies",                 "body": [             '\
            '        "Online discussies hebben een aantal problemen. Ze hebben vaak de neiging om na verloop van tijd '\
            'onoverzichtelijk te worden. De hardste schreeuwers worden het best gehoord, terwijl de meest waardevolle '\
            'reacties kunnen verdwijnen in een wolk van beledigingen. Reacties worden gepresenteerd als ellenlange wel'\
            'les-nietes discussies. Meningen van minderheden worden vaak ondergesneeuwd door populaire opinie.",      '\
            '               "Argu is ontworpen om discussie te structureren op een inhoudelijke, neutrale en oplossing'\
            'sgerichte manier. We beginnen met het identificeren van een uitdaging (het probleem). Vervolgens mag iede'\
            'reen een eigen voorstel indienen. Op deze voorstellen kan gereageerd worden in de vorm van argumenten. We'\
            ' geven de argumenten van voorstanders en tegenstanders in eigen kolommen weer, zodat beiden de kans krijg'\
            'en om hun mening zo goed mogelijk te vertegenwoordigen. Discussies worden afgebakend per argument, waardo'\
            'or er ruimte is voor diepgang. Mensen stemmen op de argumenten die zij het meest waardevol vinden in een '\
            'discussie, zodat de belangrijkste redenen bovenaan komen te staan."                 ],                 "i'\
            'mage": "product-images/motion-show-full.jpg"             }         },         {             "type": "doub'\
            'le",             "fill": true,             "right": true,             "header": "Nieuwe ideeën",         '\
            '    "body": ["Deel, ontdek en bespreek innovatieve beleidsvoorstellen. Argu maakt het gemakkelijker dan o'\
            'oit om een eigen voorstel te delen, handtekeningen te verzamelen en het geheel kritisch te evalueren."], '\
            'v            "image": "bg-landing-idee.jpg",             "expand": {                 "id": "ideeen",     '\
            '            "header": "Van idee naar beleid",                 "body": [                     "Goede ideeën'\
            ' zijn overal. Inzichten in specifieke problemen en oplossingen ontstaan vaak op de werkvloer, in het klas'\
            'lokaal of op straat.  Helaas hebben de mensen die deze ideeën krijgen vaak niet de middelen en het politi'\
            'eke netwerk om verandering te realiseren.",                     "Via Argu is het makkelijk om eigen voors'\
            'tellen te delen, te onderbouwen en handtekeningen te verzamelen. De aanwezigheid van politieke partijen o'\
            'p Argu zorgt ervoor dat de verbinding tussen de burger met een idee en de beslissingsmaker korter is dan '\
            'ooit, waardoor goede ideeën makkelijker en sneller kunnen worden omgezet naar wetgeving en beleid."      '\
            '           ],                 "image": "product-images/forum-show-full.jpg"             }         },     '\
            '    {             "type": "double",             "fill": false,             "right": false,             "h'\
            'eader": "Een onderbouwde mening",             "body": ["We worden geacht overal wat van te vinden. Argu g'\
            'eeft heldere lijsten van voor- en tegenargumenten, zodat een genuanceerde en onderbouwde mening voor iede'\
            'reen toegankelijk is."],             "image": "bg-landing-onderbouwd.jpg",             "expand": {       '\
            '          "id": "onderbouwd",                 "header": "Niet alle meningen zijn gelijk",                '\
            ' "body": [                     "Het hebben van een mening is gemakkelijk. Het hebben van een goed onderbo'\
            'uwde mening over lastige kwesties is dat niet: je moet je verdiepen in het onderwerp, veel informatie ver'\
            'zamelen uit diverse hoeken, luisteren naar verschillende voor- en tegenstanders, betrouwbare bronnen gebr'\
            'uiken en goed nadenken over de gevolgen voor alle betrokkenen.",                     "Op Argu wordt ieder'\
            'een uitgedaagd om de redenen achter een mening helder te maken. Zo zie je niet alleen wie wat vindt, maar'\
            ' ook waarom iemand dat vindt. Een heldere lijst van argumenten en een inhoudelijke discussie maakt het he'\
            'bben van een onderbouwde mening stukken makkelijker."                 ],                 "image": "produc'\
            't-images/argument-show-small.jpg"             }         },         {             "type": "double",       '\
            '      "fill": true,             "right": true,             "header": "Kritisch Stemmen",             "bod'\
            'y": ["Om politieke partijen te kunnen vergelijken, moet je goed weten wat ze vinden en waarom ze dat vind'\
            'en. Argu maakt het inhoudelijk vergelijken van partijen makkelijker dan ooit."],             "image": "bg'\
            '-landing-politiek.jpg",             "expand": {                 "id": "politiek",                 "header'\
            '": "Inhoudelijk partijen vergelijken",                 "body": [                     "Stemmen is een van '\
            'de meest directe manieren om als burger invloed te hebben op beleid. Inhoudelijk en beleidsgericht stemme'\
            'n is echter moeilijk. Politieke partijen begrijpen goed dat ze met vage uitspraken vaak meer kiezers trek'\
            'ken dan met concrete voorstellen. Zelfs in partijprogramma’s is het soms moeilijk om heldere beleidsvoors'\
            'tellen te vinden. Online stemhulpen zoals de stemwijzer geven een fijn alternatief, maar laten genoeg rui'\
            'mte over voor verbetering.",                     "Met Argu wordt het inhoudelijk vergelijken van politiek'\
            'e partijen een stuk eenvoudiger: onder een voorstel kan je direct zien wat politieke partijen er van vind'\
            'en. Op de profielpagina’s van partijen staat een duidelijke lijst van punten waar de partij het mee eens '\
            'is, en waar niet. Binnen deze lijst kan je zoeken op thema, zodat je direct weet wat een partij vindt van'\
            ' de onderwerpen die jij interessant vind."                 ],                 "image": "product-images/mo'\
            'tion-show-small-2.jpg"             }         },         {             "type": "double",             "fill'\
            '": false,             "right": false,             "header": "Sociaal lobbyen",             "body": ["Invl'\
            'oed hebben op politiek is niet voor iedereen even toegankelijk. Argu introduceert een nieuwe manier van l'\
            'obbyen waarmee iedereen met een goed idee wordt gehoord."],             "image": "bg-landing-lobby.jpg", '\
            '            "expand": {                 "id": "lobby",                 "header": "een lobby voor ieders b'\
            'elang",                 "body": [                     "Lobbyisten hebben niet de best denkbare naam. Dat '\
            'is jammer, want iedereen kan een lobbyist zijn. Iedereen kan een belang behartigen en zich inzetten voor '\
            'politieke vooruitgang. Het is echter zo dat dit een lastig proces is, waardoor organisaties met veel geld'\
            ' er behoorlijk goed in zijn. Dat schept een kromme verhouding tussen de kiezer en de beslisser.",        '\
            '             "Op Argu krijgt iedereen een eerlijke kans om eigen ideeën te delen en te onderbouwen. Daarn'\
            'a krijgen ook anderen de kans om zich in de discussie te mengen, waardoor iedereen zijn of haar belang ka'\
            'n vertegenwoordigen op een transparante en sociale manier."                 ],                 "image": "'\
            'product-images/motion-show-full.jpg"             }         }     ] }')
