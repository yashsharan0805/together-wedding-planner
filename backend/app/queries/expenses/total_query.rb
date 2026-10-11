# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

module Expenses
  class TotalQuery
    attr_reader :wedding

    def initialize(wedding:)
      @wedding = wedding
    end

    def call
      ActiveRecord::Base.connection.execute(
        ActiveRecord::Base.sanitize_sql_array([query, { wedding_id: wedding.id }])
      ).first
    end

    private

    def query
      <<~SQL.squish
        WITH guest_count AS (#{guest_count_per_status}),
             expense_summary AS (#{expense_summary}),
             payment_summary AS (#{payment_summary})
        SELECT guest_count.confirmed as confirmed_guests,
               guest_count.projected as projected_guests,
               expense_summary.fixed + expense_summary.variable * guest_count.confirmed as total_confirmed,
               expense_summary.fixed + expense_summary.variable * guest_count.projected as total_projected,
               payment_summary.total_paid as total_paid
        FROM guest_count, expense_summary, payment_summary;
      SQL
    end

    def expense_summary
      <<~SQL.squish
        SELECT coalesce(sum(amount) filter (where pricing_type = 'fixed'), 0) as fixed,
               coalesce(sum(amount) filter (where pricing_type = 'per_person'), 0) as variable
        FROM expenses
        WHERE wedding_id = :wedding_id
      SQL
    end

    def guest_count_per_status
      <<~SQL.squish
        SELECT COALESCE(count(*) filter(where status = #{Guest.statuses['confirmed']}), 0) as confirmed,
               COALESCE(count(*) filter(where status IN (#{Guest.statuses.values_at('confirmed', 'invited', 'tentative').join(',')})), 0) as projected
        FROM guests
        WHERE wedding_id = :wedding_id
      SQL
    end

    def payment_summary
      <<~SQL.squish
        SELECT coalesce(sum(amount), 0) as total_paid
        FROM payments
        WHERE wedding_id = :wedding_id
      SQL
    end
  end
end
