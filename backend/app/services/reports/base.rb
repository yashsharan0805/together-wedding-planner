# frozen_string_literal: true

module Reports
  class Base
    class << self
      attr_reader :columns

      def add_column(config)
        @columns ||= []
        @columns << config
      end
    end

    attr_reader :wedding

    def initialize(wedding:)
      @wedding = wedding
    end

    def to_h
      { columns:, rows: }
    end

    def to_csv
      CSV.generate(headers: columns.pluck(:header), write_headers: true) do |csv|
        rows.each { csv << it.values }
      end
    end

    private

    def rows
      result = rowset.pluck_to_hash(*columns_for_sql)

      self.class.columns.select { it[:transform] }.each do |column|
        result.each do |row|
          row[column[:name]] = column[:transform].call(row[column[:name]])
        end
      end

      result
    end

    def columns
      self.class.columns.map do |column|
        {
          header: I18n.t(column[:i18n_key]),
          field: column[:name]
        }
      end
    end

    def rowset
      raise NotImplementedError, 'Implement in child class'
    end

    def columns_for_sql
      self.class.columns.map do |column|
        if column[:expression]
          Arel.sql("#{column[:expression]} as #{column[:name]}")
        else
          column[:name]
        end
      end
    end
  end
end
