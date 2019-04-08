# frozen_string_literal: true

class DatasetForm < ApplicationForm
  fields [
    :display_name,
    :description,
    :identifier,
    {issued: {default_value: ->(_r) {Time.current}}},
    {modified: {default_value: ->(_r) {Time.current}}},
    {language: {sh_in: ->(_r) {language_options}}},
    {theme: {sh_in: ->(_r) {theme_options}}},
    :contact_point,
    :published_by,
    :landing_page,
    :spatial,
    :temporal,
    :authority,
    :access_rights,
    :conforms_to,
    :page,
    {accrual_periodicity: {sh_in: ->(_r) {frequency_options}}},
    :provenance,
    :version_info,
    :version_notes,
    :distributions,
    :footer
  ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 properties: [
                   creator: actor_selector
                 ]

  def self.frequency_options
    form_options(
      'accrual_periodicity',
      type: NS::SKOS[:Concept],
      options: {
        annual: {
          label: 'jaarlijks',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/ANNUAL')
        },
        annual_2: {
          label: 'halfjaarlĳks',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/ANNUAL_2')
        },
        annual_3: {
          label: 'drie keer per jaar',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/ANNUAL_3')
        },
        biennial: {
          label: 'tweejaarlijks',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/BIENNIAL')
        },
        bimonthly: {
          label: 'tweemaandelijks',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/BIMONTHLY')
        },
        biweekly: {
          label: 'veertiendaags',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/BIWEEKLY')
        },
        cont: {
          label: 'voortdurend',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/CONT')
        },
        daily: {
          label: 'dagelĳks',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/DAILY')
        },
        daily_2: {
          label: 'tweemaal per dag',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/DAILY_2')
        },
        irreg: {
          label: 'onregelmatig',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/IRREG')
        },
        monthly: {
          label: 'maandelijks',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/MONTHLY')
        },
        monthly_2: {
          label: 'twee keer per maand',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/MONTHLY_2')
        },
        monthly_3: {
          label: 'drie keer per maand',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/MONTHLY_3')
        },
        never: {
          label: 'nooit',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/NEVER')
        },
        other: {
          label: 'overige',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/OTHER')
        },
        quarterly: {
          label: 'driemaandelijks',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/QUARTERLY')
        },
        triennial: {
          label: 'driejaarlijks',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/TRIENNIAL')
        },
        unknown: {
          label: 'onbekend',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/UNKNOWN')
        },
        update_cont: {
          label: 'voortdurend geactualiseerd',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/UPDATE_CONT')
        },
        weekly: {
          label: 'wekelijks',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/WEEKLY')
        },
        weekly_2: {
          label: 'twee keer per week',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/WEEKLY_2')
        },
        weekly_3: {
          label: 'drie keer per week',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/frequency/WEEKLY_3')
        }
      }
    )
  end

  def self.language_options
    form_options(
      'language',
      type: NS::SKOS[:Concept],
      options: {
        annual: {
          label: 'Nederlands',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/language/NLD')
        },
        annual_2: {
          label: 'Engels',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/language/ENG')
        }
      }
    )
  end

  def self.theme_options
    form_options(
      'theme',
      type: NS::SKOS[:Concept],
      options: {
        afval: {
          label: 'Afval',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Afval_(thema)')
        },
        arbeidsomstandigheden: {
          label: 'Arbeidsomstandigheden',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Arbeidsomstandigheden_(thema)')
        },
        arbeidsvoorwaarden: {
          label: 'Arbeidsvoorwaarden',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Arbeidsvoorwaarden')
        },
        basisonderwijs: {
          label: 'Basisonderwijs',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Basisonderwijs_(thema)')
        },
        begroting: {
          label: 'Begroting',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Begroting')
        },
        belasting: {
          label: 'Belasting',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Belasting')
        },
        beroepsonderwijs: {
          label: 'Beroepsonderwijs',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Beroepsonderwijs_(thema)')
        },
        bestuur: {
          label: 'Bestuur',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Bestuur')
        },
        bestuursrecht: {
          label: 'Bestuursrecht',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Bestuursrecht')
        },
        bezwaar_en_klachten: {
          label: 'Bezwaar en klachten',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Bezwaar_en_klachten')
        },
        bodem: {
          label: 'Bodem',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Bodem')
        },
        bouwen_en_verbouwen: {
          label: 'Bouwen en verbouwen',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Bouwen_en_verbouwen')
        },
        bouwnijverheid: {
          label: 'Bouwnijverheid',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Bouwnijverheid')
        },
        burgerlijk_recht: {
          label: 'Burgerlijk recht',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Burgerlijk_recht')
        },
        criminaliteit: {
          label: 'Criminaliteit',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Criminaliteit')
        },
        cultuur: {
          label: 'Cultuur',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Cultuur_(thema)')
        },
        cultuur_en_recreatie: {
          label: 'Cultuur en recreatie',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Cultuur_en_recreatie')
        },
        de_nederlandse_antillen_en_aruba: {
          label: 'De Nederlandse Antillen en Aruba',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/De_Nederlandse_Antillen_en_Aruba')
        },
        defensie: {
          label: 'Defensie',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Defensie_(thema)')
        },
        dieren: {
          label: 'Dieren',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Dieren_(thema)')
        },
        economie: {
          label: 'Economie',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Economie')
        },
        emigratie: {
          label: 'Emigratie',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Emigratie_(thema)')
        },
        energie: {
          label: 'Energie',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Energie')
        },
        ethiek: {
          label: 'Ethiek',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Ethiek')
        },
        europese_zaken: {
          label: 'Europese zaken',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Europese_zaken')
        },
        financieel_toezicht: {
          label: 'Financieel toezicht',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Financieel_toezicht')
        },
        financien: {
          label: 'Financiën',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Financien')
        },
        geluid: {
          label: 'Geluid_(thema)',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Geluid_(thema)')
        },
        gemeenten: {
          label: 'Gemeenten',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Gemeenten')
        },
        geneesmiddelen_en_medische_hulpmiddelen: {
          label: 'Geneesmiddelen en medische hulpmiddelen',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Geneesmiddelen_en_medische_hulpmiddelen')
        },
        gezin_en_kinderen: {
          label: 'Gezin en kinderen',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Gezin_en_kinderen')
        },
        gezondheidsrisicos: {
          label: "Gezondheidsrisico's",
          iri: RDF::URI("http://standaarden.overheid.nl/owms/terms/Gezondheidsrisico's")
        },
        handel: {
          label: 'Handel',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Handel')
        },
        hoger_onderwijs: {
          label: 'Hoger onderwijs',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Hoger_onderwijs_(thema)')
        },
        huisvesting: {
          label: 'Huisvesting',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Huisvesting_(thema)')
        },
        huren_en_verhuren: {
          label: 'Huren en verhuren',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Huren_en_verhuren')
        },
        ict: {
          label: 'ICT',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/ICT')
        },
        immigratie: {
          label: 'Immigratie',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Immigratie_(thema)')
        },
        industrie: {
          label: 'Industrie',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Industrie_(thema)')
        },
        inkomensbeleid: {
          label: 'Inkomensbeleid',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Inkomensbeleid')
        },
        integratie: {
          label: 'Integratie',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Integratie_(thema)')
        },
        internationaal: {
          label: 'Internationaal',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Internationaal')
        },
        internationale_samenwerking: {
          label: 'Internationale samenwerking',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Internationale_samenwerking_(thema)')
        },
        jongeren: {
          label: 'Jongeren',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Jongeren_(thema)')
        },
        jongeren: {
          label: 'Jongeren',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Jongeren_(gezondheid-thema)')
        },
        koninklijk_huis: {
          label: 'Koninklijk Huis',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Koninklijk_Huis_(thema)')
        },
        kopen_en_verkopen: {
          label: 'Kopen en verkopen',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Kopen_en_verkopen')
        },
        kunst: {
          label: 'Kunst',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Kunst_(thema)')
        },
        landbouw: {
          label: 'Landbouw',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Landbouw_(thema)')
        },
        levensloop: {
          label: 'Levensloop',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Levensloop')
        },
        lucht: {
          label: 'Lucht',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Lucht')
        },
        luchtvaart: {
          label: 'Luchtvaart',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Luchtvaart')
        },
        markttoezicht: {
          label: 'Markttoezicht',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Markttoezicht')
        },
        media: {
          label: 'Media',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Media')
        },
        migratie_en_integratie: {
          label: 'Migratie en integratie',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Migratie_en_integratie')
        },
        militaire_missies: {
          label: 'Militaire missies',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Militaire_missies')
        },
        nabestaanden: {
          label: 'Nabestaanden',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Nabestaanden')
        },
        natuur_en_milieu: {
          label: 'Natuur en milieu',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Natuur_en_milieu')
        },
        natuur_en_landschapsbeheer: {
          label: 'Natuur- en landschapsbeheer',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Natuur-_en_landschapsbeheer')
        },
        nederlanderschap: {
          label: 'Nederlanderschap',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Nederlanderschap_(thema)')
        },
        netwerken: {
          label: 'Netwerken',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Netwerken')
        },
        ondernemen: {
          label: 'Ondernemen',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Ondernemen')
        },
        onderwijs_en_wetenschap: {
          label: 'Onderwijs en wetenschap',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Onderwijs_en_wetenschap')
        },
        onderzoek_en_wetenschap: {
          label: 'Onderzoek en wetenschap',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Onderzoek_en_wetenschap')
        },
        ontslag: {
          label: 'Ontslag',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Ontslag_(thema)')
        },
        ontwikkelingssamenwerking: {
          label: 'Ontwikkelingssamenwerking',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Ontwikkelingssamenwerking')
        },
        openbare_orde_en_veiligheid: {
          label: 'Openbare orde en veiligheid',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Openbare_orde_en_veiligheid')
        },
        organisatie_en_beleid: {
          label: 'Organisatie en beleid',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Organisatie_en_beleid')
        },
        ouderen: {
          label: 'Ouderen',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Ouderen')
        },
        overige_economische_sectoren: {
          label: 'Overige economische sectoren',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Overige_economische_sectoren')
        },
        overige_vormen_van_onderwijs: {
          label: 'Overige vormen van onderwijs',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Overige_vormen_van_onderwijs')
        },
        parlement: {
          label: 'Parlement',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Parlement')
        },
        planten: {
          label: 'Planten',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Planten')
        },
        politie_brandweer_en_hulpdiensten: {
          label: 'Politie, brandweer en hulpdiensten',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Politie_brandweer_en_hulpdiensten')
        },
        provincies: {
          label: 'Provincies',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Provincies')
        },
        rampen: {
          label: 'Rampen',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Rampen')
        },
        recht: {
          label: 'Recht',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Recht_(thema)')
        },
        rechtspraak: {
          label: 'Rechtspraak',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Rechtspraak')
        },
        recreatie: {
          label: 'Recreatie',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Recreatie_(thema)')
        },
        reizen: {
          label: 'Reizen',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Reizen')
        },
        religie: {
          label: 'Religie',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Religie')
        },
        rijksoverheid: {
          label: 'Rijksoverheid',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Rijksoverheid')
        },
        ruimte_en_infrastructuur: {
          label: 'Ruimte en infrastructuur',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Ruimte_en_infrastructuur')
        },
        ruimtelijke_ordening: {
          label: 'Ruimtelijke ordening',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Ruimtelijke_ordening')
        },
        sociale_zekerheid: {
          label: 'Sociale zekerheid',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Sociale_zekerheid')
        },
        spoor: {
          label: 'Spoor',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Spoor')
        },
        sport: {
          label: 'Sport',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Sport_(thema)')
        },
        staatsrecht: {
          label: 'Staatsrecht',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Staatsrecht')
        },
        staatsveiligheid: {
          label: 'Staatsveiligheid',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Staatsveiligheid')
        },
        stoffen: {
          label: 'Stoffen',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Stoffen')
        },
        strafrecht: {
          label: 'Strafrecht',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Strafrecht')
        },
        terrorisme: {
          label: 'Terrorisme',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Terrorisme_(thema)')
        },
        tijdelijk_verblijf: {
          label: 'Tijdelijk verblijf',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Tijdelijk_verblijf')
        },
        toerisme: {
          label: 'Toerisme',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Toerisme')
        },
        transport: {
          label: 'Transport',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Transport_(thema)')
        },
        verkeer: {
          label: 'Verkeer',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Verkeer_(thema)')
        },
        verzekeringen: {
          label: 'Verzekeringen',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Verzekeringen')
        },
        voeding: {
          label: 'Voeding',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Voeding')
        },
        voedselkwaliteit: {
          label: 'Voedselkwaliteit',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Voedselkwaliteit')
        },
        voortgezet_onderwijs: {
          label: 'Voortgezet onderwijs',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Voortgezet_onderwijs_(thema)')
        },
        water: {
          label: 'Water',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Water_(verkeer-thema)')
        },
        waterkeringen_en_waterbeheer: {
          label: 'Waterkeringen en waterbeheer',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Waterkeringen_en_waterbeheer')
        },
        waterschappen: {
          label: 'Waterschappen',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Waterschappen')
        },
        weg: {
          label: 'Weg',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Weg_(thema)')
        },
        werk: {
          label: 'Werk',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Werk_(thema)')
        },
        werkgelegenheid: {
          label: 'Werkgelegenheid',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Werkgelegenheid')
        },
        werkloosheid: {
          label: 'Werkloosheid',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Werkloosheid')
        },
        ziekte_en_arbeidsongeschiktheid: {
          label: 'Ziekte en arbeidsongeschiktheid',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Ziekte_en_arbeidsongeschiktheid')
        },
        ziekten_en_behandelingen: {
          label: 'Ziekten en behandelingen',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Ziekten_en_behandelingen')
        },
        zorg_en_gezondheid: {
          label: 'Zorg en gezondheid',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/Zorg_en_gezondheid')
        }
      }
    )
  end
end


