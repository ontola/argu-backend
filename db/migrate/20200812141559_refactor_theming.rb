class RefactorTheming < ActiveRecord::Migration[6.0]
  def change
    Property.where(predicate: NS::ARGU[:navbarBackground].to_s).where('string != ?', '#475668').pluck(:edge_id, :string).each do |edge_id, color|
      if color == '#FFFFFF'
        Page.find_by(uuid: edge_id).update(
          header_background: 'background_white',
          header_text: 'text_primary',
          primary_color: Property.find_by(edge_id: edge_id, predicate: NS::ARGU[:navbarColor].to_s).string
        )
      else
        Page.find_by(uuid: edge_id).update(primary_color: color)
      end
    end
    Property.where(predicate: NS::ARGU[:accentBackgroundColor].to_s).where('string != ?', '#475668').pluck(:edge_id, :string).each do |edge_id, color|
      page = Page.find_by(uuid: edge_id)
      page.update(secondary_color: color) if color != page.primary_color
    end

    Page.find_via_shortname('groenlinks')&.update(
      home_menu_image: 'http://fontawesome.io/icon/home',
      template: 'groenLinks',
      header_background: 'background_white',
      header_text: 'text_auto',
      primary_color: '#39a935',
      secondary_color: '#dd0031',
    )
  end
end
