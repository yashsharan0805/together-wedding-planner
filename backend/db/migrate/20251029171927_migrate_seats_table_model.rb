# frozen_string_literal: true

class MigrateSeatsTableModel < ActiveRecord::Migration[8.0]
  def up
    Wedding.find_each do |wedding|
      ActsAsTenant.with_tenant(wedding) do
        wedding.tables_arrangements.find_each do |arrangement|
          migrate_arrangement(arrangement)
        end
      end
    end
  end

  def down
    ActsAsTenant.without_tenant do
      Seat.where.not(table_number: nil).in_batches.update_all(table_id: nil) # Nullify only seats that were migrated
      Table.in_batches.delete_all
    end
  end

  private

  def migrate_arrangement(arrangement)
    table_numbers = arrangement.seats
                               .where.not(table_number: nil)
                               .select(:table_number)
                               .distinct
                               .pluck(:table_number)

    tables_data = table_numbers.map do |table_number|
      {
        wedding_id: arrangement.wedding_id,
        tables_arrangement_id: arrangement.id,
        number: table_number + 1, # Increment table number by 1 to avoid zero-based indexing
        capacity: 8..10 # Default capacity range prior to having specific capacities
      }
    end

    Table.insert_all!(tables_data)

    Table.find_each do |table|
      arrangement.seats.where(table_number: table[:number] - 1) # Decrement to match original seat numbering
                 .update_all(table_id: table.id)
    end
  end
end
