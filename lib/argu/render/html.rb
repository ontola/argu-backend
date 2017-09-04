# frozen_string_literal: true

module Argu
  module Render
    class HTML < Redcarpet::Render::HTML
      include ActionView::Helpers::TagHelper
      include ActionView::Context

      def initialize(options = {})
        @options = options
        super
      end

      def link(link, title, content)
        safe_content = content&.html_safe
        content =
          case link_get_type(link)
          when 'u'
            content_tag :span, safe_content, class: 'markdown--profile'
          when 'm'
            content_with_detail_icon(safe_content, 'motion', 'lightbulb-o')
          when 'q'
            content_with_detail_icon(safe_content, 'question', 'question')
          when 'a'
            pro, title = Argument.where(id: link.split('/').last).pluck(:pro, :title).first
            content_tag :span, class: "markdown--argument-#{pro ? 'pro' : 'con'}" do
              safe_join([content_tag(:span, '', class: "argument-bg fa fa-#{pro ? 'plus' : 'minus'}"), safe_content])
            end
          else
            content
          end
        content_tag :a, content, title: title, href: link, target: '_blank'
      end

      def paragraph(text)
        @options[:no_paragraph] ? text : content_tag(:p, text.html_safe)
      end

      private

      def content_with_detail_icon(content, type, fa)
        content_tag :span, class: "markdown--#{type}" do
          safe_join(
            [
              content_tag(:span, class: "detail__icon detail__icon--inline #{type}-bg") do
                content_tag :span, '', class: "fa fa-#{fa}"
              end,
              content
            ]
          )
        end
      end

      def link_get_type(link)
        return if link.nil?
        elements = link.split('/')
        return unless elements.first == '' || elements.include?(Rails.application.config.host_name)
        elements[elements.length - 2]
      end
    end
  end
end
