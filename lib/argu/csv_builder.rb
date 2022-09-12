# frozen_string_literal: true

module Argu
  class CSVBuilder
    DEFAULT_OPTIONS = {headers: true, col_sep: ';', force_quotes: true}.freeze

    attr_accessor :columns, :csv_options, :rows

    def initialize(columns:, rows:, csv_options: {})
      self.columns = columns
      self.csv_options = DEFAULT_OPTIONS.merge(csv_options)
      self.rows = rows
    end

    def generate(&block)
      CSV.generate(**csv_options) do |csv|
        csv << headers
        rows.each { |object| csv << row(object, &block) }
      end
    end

    private

    def headers
      columns.map do |attr|
        attr.fetch(:label)
      end
    end

    def row(object)
      columns.map do |column|
        yield(object, column)
      end
    end
  end
end
