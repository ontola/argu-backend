# frozen_string_literal: true

module EmailActionsHelper
  def goto_action(options)
    helper_data = {
      '@context' => 'http://schema.org',
      '@type' => 'EmailMessage',
      potentialaction: {
        '@type' => 'ViewAction',
        name: options[:name],
        target: options[:url]
      }
    }

    content_tag :script, type: 'application/ld+json' do
      helper_data.to_json.html_safe
    end
  end
end
