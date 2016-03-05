require 'rails_helper'

RSpec.feature 'Collapsible', type: :feature do

  # Names need be different since header_helper#public_forum_items checks for those names
  let!(:freetown) { create(:forum, name: 'freetown') }
  let!(:motion) { create(:motion, forum: freetown) }
  let!(:argument) { create(:argument, motion: motion, content: "This is a string that is long enough to make sure that the collapsible element is used in the view. The content that should be visisble appears on the end of this string. First, we will just talk. How is life, my friend? Are you happy with who you are? Now here's the important part: the content that should be visisble **after clicking**") }

  scenario 'User expands ' do
    visit motion_path(motion)

    val = page.evaluate_script("document.querySelector('##{argument.identifier}').clientHeight")

    page.execute_script("$('##{argument.identifier} label.collapsible-label').click()")

    val_after = page.evaluate_script("document.querySelector('##{argument.identifier}').clientHeight")

    expect(val_after).to be > val + 30
  end
end