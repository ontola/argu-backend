# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

User
  .create(
    id: 0,
    shortname: Shortname.new(shortname: 'community'),
    email: 'community@argu.co',
    password: 'password',
    finished_intro: true,
    profile: Profile.create(id: 0))

User
  .create!(
    email: 'staff@argu.co',
    shortname_attributes: {shortname: 'staff_account'},
    password: 'arguargu',
    password_confirmation:'arguargu',
    first_name: 'Douglas',
    last_name: 'Engelbart',
    finished_intro: true,
    profile: Profile.new)
  .profile
  .add_role :staff

User
  .new(
    email: 'user@argu.co',
    shortname_attributes: {shortname: 'user_account'},
    password: 'arguargu',
    password_confirmation:'arguargu',
    first_name: 'Maarten',
    last_name: 'Scharendrecht',
    finished_intro: true,
    profile: Profile.new)
  .profile
  .add_role :user

argu = Page
         .create!(
           owner: User.find_via_shortname('staff_account').profile,
           shortname_attributes: {shortname: 'argu'},
           profile: Profile.new(name: 'Argu'),
           last_accepted: Time.current)

Forum.create!(name: 'Nederland',
             page: argu,
             shortname_attributes: {shortname: 'nederland'})

Setting.set('user_cap', -1)
Setting.set('quotes', 'Argumenten moet men wegen, niet tellen.')

Setting.set('about', '{     "header": "Over onze visie",     "sections": [         {             "type": "single",             "fill": false,             "slogan": true,             "body": [                 "Argu is een online discussieplatform voor ieder die mee wil denken over het oplossen van problemen. Argu maakt discussies overzichtelijk door uitdagingen, voorstellen en argumenten centraal te stellen."                 ]         },         {             "type": "double",             "fill": true,             "right": true,             "header": "Politiek moet inhoudelijker",             "body": ["Politieke discussies moeten gaan over het oplossen van problemen; niet over TV-optredens en one-liners."],             "image": "bg-landing-hong-kong.jpg",             "expand": {                 "id": "inhoudelijker",                 "header": "Politiek moet inhoudelijker",                 "body": [                     "Politiek bestaat te veel uit marketing en te weinig uit zinvolle, oplossingsgerichte discussies. Dat is zonde, want politieke beslissingen gaan ons allemaal aan. Leven in een democratie betekent meer dan eens in de zoveel jaar naar een stemhokje gaan; het betekent dat wij allemaal mee kunnen denken over hoe we onze grootste problemen gaan oplossen.",                     "Internet heeft veranderd hoe we met elkaar communiceren, hoe we leren en hoe we ons ontwikkelen. Social media heeft meer mensen een stem gegeven, maar heeft nog niet de inhoud en diepgang kunnen bieden die nodig is voor inhoudelijke discussies. Discussies over lastige onderwerpen passen niet in 140 karakters. Democratie heeft een modern platform nodig."                 ]             }         },         {             "type": "double",             "fill": false,             "right": false,             "header": "Gestructureerde discussies",             "body": ["Discussies op internet kunnen veel beter. Argu introduceert een unieke structuur om discussies overzichtelijk en oplossingsgericht te houden."],             "image": "bg-landing-stemmen.jpg",             "expand": {                 "id": "discussies",                 "header": "Tijd voor goede online discussies",                 "body": [                     "Online discussies hebben een aantal problemen. Ze hebben vaak de neiging om na verloop van tijd onoverzichtelijk te worden. De hardste schreeuwers worden het best gehoord, terwijl de meest waardevolle reacties kunnen verdwijnen in een wolk van beledigingen. Reacties worden gepresenteerd als ellenlange welles-nietes discussies. Meningen van minderheden worden vaak ondergesneeuwd door populaire opinie.",                     "Argu is ontworpen om discussie te structureren op een inhoudelijke, neutrale en oplossingsgerichte manier. We beginnen met het identificeren van een uitdaging (het probleem). Vervolgens mag iedereen een eigen voorstel indienen. Op deze voorstellen kan gereageerd worden in de vorm van argumenten. We geven de argumenten van voorstanders en tegenstanders in eigen kolommen weer, zodat beiden de kans krijgen om hun mening zo goed mogelijk te vertegenwoordigen. Discussies worden afgebakend per argument, waardoor er ruimte is voor diepgang. Mensen stemmen op de argumenten die zij het meest waardevol vinden in een discussie, zodat de belangrijkste redenen bovenaan komen te staan."                 ],                 "image": "product-images/motion-show-full.jpg"             }         },         {             "type": "double",             "fill": true,             "right": true,             "header": "Nieuwe ideeën",             "body": ["Deel, ontdek en bespreek innovatieve beleidsvoorstellen. Argu maakt het gemakkelijker dan ooit om een eigen voorstel te delen, handtekeningen te verzamelen en het geheel kritisch te evalueren."],             "image": "bg-landing-idee.jpg",             "expand": {                 "id": "ideeen",                 "header": "Van idee naar beleid",                 "body": [                     "Goede ideeën zijn overal. Inzichten in specifieke problemen en oplossingen ontstaan vaak op de werkvloer, in het klaslokaal of op straat.  Helaas hebben de mensen die deze ideeën krijgen vaak niet de middelen en het politieke netwerk om verandering te realiseren.",                     "Via Argu is het makkelijk om eigen voorstellen te delen, te onderbouwen en handtekeningen te verzamelen. De aanwezigheid van politieke partijen op Argu zorgt ervoor dat de verbinding tussen de burger met een idee en de beslissingsmaker korter is dan ooit, waardoor goede ideeën makkelijker en sneller kunnen worden omgezet naar wetgeving en beleid."                 ],                 "image": "product-images/forum-show-full.jpg"             }         },         {             "type": "double",             "fill": false,             "right": false,             "header": "Een onderbouwde mening",             "body": ["We worden geacht overal wat van te vinden. Argu geeft heldere lijsten van voor- en tegenargumenten, zodat een genuanceerde en onderbouwde mening voor iedereen toegankelijk is."],             "image": "bg-landing-onderbouwd.jpg",             "expand": {                 "id": "onderbouwd",                 "header": "Niet alle meningen zijn gelijk",                 "body": [                     "Het hebben van een mening is gemakkelijk. Het hebben van een goed onderbouwde mening over lastige kwesties is dat niet: je moet je verdiepen in het onderwerp, veel informatie verzamelen uit diverse hoeken, luisteren naar verschillende voor- en tegenstanders, betrouwbare bronnen gebruiken en goed nadenken over de gevolgen voor alle betrokkenen.",                     "Op Argu wordt iedereen uitgedaagd om de redenen achter een mening helder te maken. Zo zie je niet alleen wie wat vindt, maar ook waarom iemand dat vindt. Een heldere lijst van argumenten en een inhoudelijke discussie maakt het hebben van een onderbouwde mening stukken makkelijker."                 ],                 "image": "product-images/argument-show-small.jpg"             }         },         {             "type": "double",             "fill": true,             "right": true,             "header": "Kritisch Stemmen",             "body": ["Om politieke partijen te kunnen vergelijken, moet je goed weten wat ze vinden en waarom ze dat vinden. Argu maakt het inhoudelijk vergelijken van partijen makkelijker dan ooit."],             "image": "bg-landing-politiek.jpg",             "expand": {                 "id": "politiek",                 "header": "Inhoudelijk partijen vergelijken",                 "body": [                     "Stemmen is een van de meest directe manieren om als burger invloed te hebben op beleid. Inhoudelijk en beleidsgericht stemmen is echter moeilijk. Politieke partijen begrijpen goed dat ze met vage uitspraken vaak meer kiezers trekken dan met concrete voorstellen. Zelfs in partijprogramma’s is het soms moeilijk om heldere beleidsvoorstellen te vinden. Online stemhulpen zoals de stemwijzer geven een fijn alternatief, maar laten genoeg ruimte over voor verbetering.",                     "Met Argu wordt het inhoudelijk vergelijken van politieke partijen een stuk eenvoudiger: onder een voorstel kan je direct zien wat politieke partijen er van vinden. Op de profielpagina’s van partijen staat een duidelijke lijst van punten waar de partij het mee eens is, en waar niet. Binnen deze lijst kan je zoeken op thema, zodat je direct weet wat een partij vindt van de onderwerpen die jij interessant vind."                 ],                 "image": "product-images/motion-show-small-2.jpg"             }         },         {             "type": "double",             "fill": false,             "right": false,             "header": "Sociaal lobbyen",             "body": ["Invloed hebben op politiek is niet voor iedereen even toegankelijk. Argu introduceert een nieuwe manier van lobbyen waarmee iedereen met een goed idee wordt gehoord."],             "image": "bg-landing-lobby.jpg",             "expand": {                 "id": "lobby",                 "header": "een lobby voor ieders belang",                 "body": [                     "Lobbyisten hebben niet de best denkbare naam. Dat is jammer, want iedereen kan een lobbyist zijn. Iedereen kan een belang behartigen en zich inzetten voor politieke vooruitgang. Het is echter zo dat dit een lastig proces is, waardoor organisaties met veel geld er behoorlijk goed in zijn. Dat schept een kromme verhouding tussen de kiezer en de beslisser.",                     "Op Argu krijgt iedereen een eerlijke kans om eigen ideeën te delen en te onderbouwen. Daarna krijgen ook anderen de kans om zich in de discussie te mengen, waardoor iedereen zijn of haar belang kan vertegenwoordigen op een transparante en sociale manier."                 ],                 "image": "product-images/motion-show-full.jpg"             }         }     ] }')
