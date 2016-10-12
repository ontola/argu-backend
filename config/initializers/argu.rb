# frozen_string_literal: true
require 'argu/stateful_server_renderer'
Dir['/argu/*.rb'].each { |file| require file }
[Forum, Question, Motion, Argument, Comment, Project].freeze
