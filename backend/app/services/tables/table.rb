# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

module Tables
  class Table < Set
    attr_accessor :discomfort, :min_per_table, :max_per_table, :number, :name

    def initialize(*args)
      super
      reset
    end

    def reset
      original_discomfort = discomfort
      @discomfort = nil
      original_discomfort
    end
  end
end
