class MigrateShortnames < ActiveRecord::Migration[5.1]
  def up
    [
      ['provinciezuidholland', 'zuidholland'], ['onshuis_apeldoorn', 'onshuis'], ['stichting_boex', 'boex'], ['UvA_FdR', 'UvA'], ['gemeente_rotterdam', 'rotterdam'], ['gemeente_roermond', 'roermond'], ['woningcorporatie_prewonen', 'prewonen'], ['ordinabv', 'ordina'],
      ['woonstad_rotterdam', 'Woonstad'], ['gemeentehouten', 'houten'], ['wooninc_eindhoven', 'wooninc'], ['thuis_vester', 'thuisvester'], ['bedrijfx', 'demobedrijf'], ['studentenstarterutrecht', 'stusta'], ['benvalor_advocaten', 'benvalor'], ['stichting_groenwest', 'groenwest'],
      ['gemeente_oegstgeest', 'oegstgeest'], ['stichting_accolade', 'accolade'], ['Stichting_Ymere', 'ymere'], ['Mitros_Utrecht', 'mitros'], ['Woningcorporatie_WoonFriesland', 'woonfriesland'], ['Woningstichting_De_Woonplaats', 'de_woonplaats'], ['gemeentebaarn', 'baarn'],
      ['quawonen_organisatie', 'QuaWonen'], ['positieflinks_organisatie', 'PositiefLinks'], ['helmondgemeente', 'helmond'], ['gemeente_delft', 'delft'], ['Vivare_Arnhem', 'vivare'], ['knltb_nederland', 'knltb'], ['Stichting_Woonzorg', 'woonzorg'],
      ['gemeente_alkmaar', 'alkmaar'], ['stichting_nijestee', 'nijestee'], ['utrechtprovincie', 'provincieutrecht'], ['gemeentewijkbijduurstede', 'wijkbijduurstede'], ['gemeenteoosterhout', 'oosterhout'], ['gemeente_almelo', 'almelo'], ['speakingmindsorg', 'speakingminds'],
      ['gemeente_meppel', 'meppel'], ['gemeentesoest', 'soest'], ['Stichting_Lefier', 'lefier'], ['Rochdale_Amsterdam', 'rochdale'], ['woonstichting_de_key', 'de_key'], ['wbv_vechtenomstreken', 'vechtenomstreken'], ['gemeente_utrecht', 'utrecht'], ['feedbackheineken', 'heineken'],
      ['woonstede_ede', 'woonstede'], ['Stichting_Portaal', 'portaal'], ['Woningstichting_Haag_Wonen', 'haag_wonen'], ['Stichting_Woonpunt', 'woonpunt'], ['gemeenteharen', 'haren'], ['dietz_utrecht', 'Dietz'], ['honderd_procent_groningen', 'honderdprocentgroningen'],
      ['gemeente_ooststellingwerf', 'ooststellingwerf'], ['laurentiuswonen', 'laurentius'], ['stichting_mooiland', 'mooiland'], ['gemeente_breda', 'breda'], ['gemeente_zwolle', 'zwolle'], ['gemeente_groningen', 'groningen'], ['gemeentedordrecht', 'dordrecht'],
      ['ONLvoorondernemers', 'onl'], ['gemeenteschiedam', 'schiedam'], ['rijnhart_wonen', 'rijnhart'], ['woonbedrijf_sws', 'woonbedrijf'], ['Staedion_DenHaag', 'staedion'], ['Stadgenoot_Amsterdam', 'stadgenoot'], ['wonen_zuid', 'wonenzuid'], ['gemeenteHollandsKroon', 'hollandskroon'],
      ['gemeentelelystad', 'lelystad'], ['tiwos_wonen', 'tiwos'], ['gemeente_leusden', 'leusden'], ['woningstichting_eigenhaard', 'eigen_haard'], ['gemeente_amstelveen', 'amstelveen'], ['gemeenteheerenveen', 'heerenveen'], ['gemeente_vlissingen', 'vlissingen'],
      ['UnframedOrg', 'unframed'], ['gemeente_zeist', 'zeist'], ['five_analytics', 'FiveAnalytics'], ['woonbestuurcambridgelaan', 'cambridgelaan'], ['alliander_organisatie', 'alliander'], ['gemeente_velsen', 'velsen'], ['woonconcept_nederland', 'woonconcept'],
      ['gemeente_opsterland', 'opsterland'], ['gemeente_almere', 'almere'], ['SSH_XL', 'sshxl'], ['provinciegelderland', 'gelderland'], ['bergen_op_zoom', 'bergenopzoom'], ['gemeente_hoorn', 'hoorn'], ['Stichting_de_Alliantie', 'de_alliantie'], ['stadsdeelwest', 'amsterdamwest'],
      ['lifelines_groningen', 'lifelines'], ['a4b_intern', 'a4b'], ['dwars_groenlinkse_jongeren', 'DWARS'], ['knwu_nederland', 'knwu']
    ].each do |old, new|
      owner = Shortname.find_by!(shortname: old, root_id: nil).owner
      shortname = Shortname.find_or_initialize_by(shortname: new, root_id: nil)
      shortname.update!(owner: owner, primary: true)
    end

    Shortname.where('root_id IS NOT NULL AND shortname LIKE ?', '%intern%').update_all(shortname: 'intern')

    uuids = Edge.where(owner_type: 'Forum').joins(:shortnames, parent: :shortnames).where(shortnames: {primary: true}).where('shortnames.shortname = shortnames_edges.shortname').pluck(:uuid)
    Shortname.where(owner_type: 'Edge', owner_id: uuids).update_all(shortname: 'forum')

    Forum.find_via_shortname('nederland').edge.shortname.update!(shortname: 'forum', primary: true)
    Page.find_via_shortname('nld').update(url: 'nederland')

  end
end

