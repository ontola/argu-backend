# frozen_string_literal: true

class CustomReporter < Minitest::Reporters::BaseReporter
  include Minitest::RelativePosition
  include Minitest::Reporters::ANSI::Code

  attr_accessor :total_fails

  def initialize(**options)
    self.total_fails = 0
    super
    io.sync = true
  end

  def before_suite(test)
    puts test.name

    super
  end

  def record(test)
    super
    return if test.skipped?

    failure_message(test) if test.failure

    eta_message
  end

  def report # rubocop:disable Metrics/AbcSize
    super

    puts
    puts(format('Finished in %<time>.5fs', time: total_time))
    print(format('%<count>d tests, %<assertions>d assertions, ', count: count, assertions: assertions))
    color = failures.zero? && errors.zero? ? :green : :red
    print(send(color) { format('%<failures>d failures, %<errors>d errors, ', failures: failures, errors: errors) })
    print(yellow { format('%<skips>d skips', skips: skips) })
    puts
  end

  private

  def eta_message(progress = count / total_count.to_f)
    puts(
      format(
        '%<perc>.2f%% - %<failures>s - ETA: %<time>s',
        failures: total_fails.positive? ? format('FAILURES: %<failures>s', failures: total_fails) : 'ALL GREEN',
        perc: (100 * progress),
        time: format_time((total_time / progress) - total_time)
      )
    )
  end

  def failure_message(test)
    self.total_fails += 1

    print "\e[0m\e[1000D\e[K"
    print result(test).to_s.upcase
    print_test_with_time(test)
    puts
    print_info(test.failure, test.error?)
    puts
  end

  def format_time(time)
    t = time.to_i
    sec = t % 60
    min = (t / 60) % 60
    hour = t / 3600
    format('%<hour>02d:%<min>02d:%<sec>02d', hour: hour, min: min, sec: sec)
  end

  def print_test_with_time(test)
    puts [test.name, test_class(test), total_time].inspect
    print(format(' %<name>s#%<klass>s (%<time>.2fs)', name: test.name, klass: test_class(test), time: total_time))
  end
end
