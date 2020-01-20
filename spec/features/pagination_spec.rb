# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Pagination', type: :feature do
  define_common_objects(:freetown, :user)

  let(:overpopulated_motion) do
    m = create(:motion, parent: freetown)
    create_list(:argument,
                6,
                pro: true,
                parent: m)
    create_list(:argument,
                6,
                pro: false,
                parent: m)
    m
  end

  css_pro_pagination = '.argument-columns .col-2-1:nth-child(2) .pagination'
  css_con_pagination = '.argument-columns .col-2-1:nth-child(3) .pagination'

  scenario 'Guest clicks on argument next' do
    m = overpopulated_motion
    args = m.arguments.order(id: :asc)
    p_args = args.where(owner_type: 'ProArgument')
    c_args = args.where(owner_type: 'ConArgument')
    first_pro = p_args.first.display_name
    last_pro = p_args.to_a.last.display_name
    first_con = c_args.to_a.first.display_name
    last_con = c_args.last.display_name
    expect(m.arguments.where(owner_type: 'ProArgument').length).to(be > 5)

    visit m
    expect(page).to have_content(m.display_name)

    expect(page).to have_content(first_pro)
    expect(page).to have_content(first_con)
    expect(page).not_to have_content(last_pro)
    expect(page).not_to have_content(last_con)

    within(css_pro_pagination) do
      click_link 'next ›'
    end

    expect(page).not_to have_content(first_pro)
    expect(page).to have_content(first_con)
    expect(page).to have_content(last_pro)
    expect(page).not_to have_content(last_con)

    within(css_con_pagination) do
      click_link 'next ›'
    end

    expect(page).not_to have_content(first_pro)
    expect(page).not_to have_content(first_con)
    expect(page).to have_content(last_pro)
    expect(page).to have_content(last_con)
  end
end
