# frozen_string_literal: true

module EmailActionsHelper
  def confirm_action(options)
    helper_data = {
      '@context' => 'http://schema.org',
      '@type' => 'EmailMessage',
      action: {
        '@type' => 'ConfirmAction',
        name: options[:name],
        handler: {
          '@type' => 'HttpActionHandler',
          url: options[:url]
        }
      }
    }

    content_tag :script, type: 'application/ld+json' do
      helper_data.to_json.html_safe
    end
  end

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
