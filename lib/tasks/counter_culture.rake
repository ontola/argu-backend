# frozen_string_literal: true

namespace :counter_culture do
  desc 'Reset the counter_culture columns'
  task reset: :environment do
    puts_result Follow.counter_culture_fix_counts
    puts_result MediaObject.counter_culture_fix_counts
    [Motion, Question, ProArgument, ConArgument, BlogPost, Vote, VoteEvent, Comment]
      .each { |c| puts_result(c.fix_counts) }
    puts 'CounterCulture columns are reset'
  end

  def puts_result(array)
    array.each do |result|
      puts "#{result[:entity]} #{result[:id]}: #{result[:what]} is set to #{result[:right]} (was #{result[:wrong]})"
    end
  end
end
