require 'rails_helper'

RSpec.feature 'Signup', type: :feature do
  let!(:default_forum) { create(:setting, key: 'default_forum', value: 'default') }
  let!(:default) { create(:forum, name: 'default') }
  let!(:freetown) { create(:forum, name: 'freetown') }
  let!(:motion) { create(:motion, forum: freetown) }

  scenario 'should register w/ oauth and preserve vote on non-default forum' do
    OmniAuth.config.mock_auth[:facebook] =
      OmniAuth::AuthHash.new(
        {
          provider: 'facebook',
          uid: '111907595807605',
          credentials: {
            token: 'CAAKvnjt9N54BACAJ6Uj5LFywuhmo5vy2VUyvBqtZAPrZAUH10sy4KgxZAU0mZConMqV9ZB6kO4eZCC3Y822NbZCXdBjZAjUE9ubUscZBZB5WGHn32jIn2NU7UZAVYbAYWcmfg0vutOLZAw3LDs8YE2O5k2Nwde7zzMK1hyBrZC30wvIFnbjoaGegXEZBbL1fyJjGTUBLADCOczzZAHkDhH3mYqJp2y2'
          },
          info: {
            email: 'testuser@example.com',
            first_name: 'First',
            last_name: 'Last'
          },
          extra: {
            raw_info: {
              middle_name: 'Middle'
            }
          }
        })

    visit root_path
    expect(page).to have_content 'default'
    expect(current_path).to eq forum_path(default)

    visit forum_path(freetown)
    expect(page).to have_content 'freetown'

    click_link motion.title
    expect(page).to have_content(motion.content)

    click_link 'Neutral'
    expect(page).to have_content 'Sign up'

    click_link 'Log in with Facebook'

    expect(current_path).to eq setup_users_path
    click_button 'Volgende'

    click_button 'Geen van beide'

    expect(page).to have_content motion.title
    expect(page).to have_css 'a.btn-neutral[data-voted-on=true]'
  end

  scenario 'should register with country only' do
    stub_request(:get, 'https://nominatim.openstreetmap.org/search?addressdetails=1&country=nl&extratags=1&format=jsonv2&limit=1&namedetails=1&polygon=0&postalcode=')
      .to_return(body: [
        {
          place_id: "144005013",
          licence: "Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright",
          osm_type: "relation",
          osm_id: "2323309",
          boundingbox: [
            '11.777',
            '53.7253321',
            '-70.2695875',
            '7.2274985'
          ],
          lat: "52.5001698",
          lon: "5.7480821",
          display_name: "The Netherlands",
          place_rank: "4",
          category: "boundary",
          type: "administrative",
          importance: 0.4612931222686,
          icon: "https://nominatim.openstreetmap.org/images/mapicons/poi_boundary_administrative.p.20.png",
          address: {
            country: "The Netherlands",
            country_code: "nl"
          },
          extratags: {
            place: "country",
            wikidata: "Q29999",
            wikipedia: "nl:Koninkrijk der Nederlanden",
            population: "16645313"
          },
          namedetails: {
            name: "Nederland",
            int_name: "Nederland"
          }
        }
      ].to_json)

    visit new_user_session_path

    click_link 'Sign up with email'

    user_attrs = attributes_for(:user)

    within('#new_user') do
      fill_in 'user_email', with: user_attrs[:email]
      fill_in 'user_password', with: user_attrs[:password]
      fill_in 'user_password_confirmation', with: user_attrs[:password_confirmation]
      click_button 'Sign up'
    end

    expect(current_path).to eq setup_users_path
    click_button 'Volgende'

    within('#profile_profileable_attributes_home_placement_attributes_country_code_input') do
      input_field = find('.Select-control .Select-input input').native
      input_field.send_keys 'Nederland'
      find('.Select-option', text: /Nederland$/).click
    end
    click_button 'Volgende'

    expect(current_path).to eq(user_path(User.last))
  end

end
