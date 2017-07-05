# frozen_string_literal: true
require 'argu/stateful_server_renderer'
Dir['/argu/*.rb'].each { |file| require file }
[Page, Forum, Question, Motion, Argument, Comment, Project, BlogPost, Group].freeze
