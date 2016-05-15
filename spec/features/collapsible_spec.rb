require 'rails_helper'

RSpec.feature 'Collapsible', type: :feature do
  # Names need be different since header_helper#public_forum_items checks for those names
  define_common_objects :freetown, :motion!
  let!(:argument) do
    create(:argument,
           motion: motion,
           content: 'This is a string that is long enough to make sure that the collapsible element is used in the vie'\
           'w. The content that should be visisble appears on the end of this string. First, we will just talk. How is'\
           " life, my friend? Are you happy with who you are? Now here's the important part: the content that should b"\
           'e visisble **after clicking**')
  end

  scenario 'Guest expands ' do
    visit motion_path(motion)

    val = page.evaluate_script("document.querySelector('##{argument.identifier}').clientHeight")

    page.execute_script("$('##{argument.identifier} label.collapsible-label').click()")

    val_after = page.evaluate_script("document.querySelector('##{argument.identifier}').clientHeight")

    expect(val_after).to be > val + 30
  end
end
