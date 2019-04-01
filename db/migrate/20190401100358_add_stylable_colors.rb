class AddStylableColors < ActiveRecord::Migration[5.2]
  def change
    Page.all.map do |p|
      ActsAsTenant.with_tenant(p) do
        if p.base_color
          p.update(accent_background_color: p.base_color,
                   navbar_background: p.base_color)
        end
      end
    end

    kvk = Page.find_via_shortname('kvk')
    ActsAsTenant.with_tenant(kvk) do
      kvk.update(accent_background_color: '#AA418C',
                 navbar_background: 'linear-gradient(to right, #853177 0%,#E96A0E 100%)')
    end
  end
end
