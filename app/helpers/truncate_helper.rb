# frozen_string_literal: true

module TruncateHelper
  include MarkdownHelper, ActionView::Helpers::TagHelper

  # @param [String] contents The text to truncate
  # @param [Integer] cutting_point The ammount of chars before cutting
  # @param [Hash] opts Additional options to pass to HTML_Truncator
  # @return [String] Truncated, safe html version of the {contents} markdown string
  def safe_truncated_text(contents, cutting_point = 220, opts = {})
    opts = {ellipsis: '...', length_in_chars: true}.merge(opts)
    adjusted_content = markdown_to_plaintext(contents)
    escape_once HTML_Truncator.truncate(adjusted_content,
                                        cutting_point,
                                        opts)
  end
end
