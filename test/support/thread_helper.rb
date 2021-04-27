# frozen_string_literal: true

module ThreadHelper
  UnstubbedThread = Thread.dup

  class ThreadResult
    attr_accessor :value

    def initialize(value: nil)
      @value = value
    end

    def join
      self
    end
  end

  def thread_stub(matcher)
    stub = lambda do |*args, &block|
      matcher.call(*args) ? ThreadResult.new(value: block.call(*args)) : UnstubbedThread.new(*args, &block)
    end

    Thread.stub(:new, stub) do
      yield
    end
  end
end
