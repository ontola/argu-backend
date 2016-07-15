# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Manager', type: :feature do
  define_freetown('nederland')
  let!(:user) { create(:user) }
  let!(:member) { create_member(nederland) }

  scenario 'Owner adds a manager' do
    sign_in(nederland.edge.parent.owner.owner.profileable)

    visit(settings_forum_path(nederland, tab: :managers))

    click_link('Add manager')
    within('form.membership') do
      selector =
        if Capybara.current_driver == :poltergeist
          '.Select-control .Select-placeholder'
        else
          '.Select-control .Select-input input'
        end
      input_field = find(selector).native
      input_field.send_keys user.first_name
      find('.Select-option').click

      click_button 'Create Membership'
    end

    expect(
      find(".managers .#{user.profile.identifier} .name",
           text: user.display_name)
    ).to be_present
  end

  scenario 'Owner adds a member manager' do
    sign_in(nederland.edge.parent.owner.owner.profileable)

    visit(settings_forum_path(nederland, tab: :managers))

    click_link('Add manager')
    within('form.membership') do
      selector =
        if Capybara.current_driver == :poltergeist
          '.Select-control .Select-placeholder'
        else
          '.Select-control .Select-input input'
        end
      input_field = find(selector).native
      input_field.send_keys member.first_name
      find('.Select-option').click

      click_button 'Create Membership'
    end

    expect(
      find(".managers .#{member.profile.identifier} .name",
           text: member.display_name)
    ).to be_present
  end
end
