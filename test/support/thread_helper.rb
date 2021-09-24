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

  def thread_stub(matcher, &block)
    stub = lambda do |*args, &stub_block|
      matcher.call(*args) ? ThreadResult.new(value: stub_block.call(*args)) : UnstubbedThread.new(*args, &stub_block)
    end

    Thread.stub(:new, stub, &block)
  end
end
