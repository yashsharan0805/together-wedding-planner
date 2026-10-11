# frozen_string_literal: true

class SolutionPersister
  attr_reader :simulation, :solution

  def initialize(simulation, solution)
    @simulation = simulation
    @solution = solution
  end

  def call
    @table_names = simulation.tables.where.not(name: nil).pluck(:id, :name).to_h

    delete_old_records
    create_tables
    create_seats
  end

  private

  def delete_old_records
    simulation.tables.delete_all # Seats are deleted on cascade
  end

  def create_tables
    new_tables = solution.each_with_index.map do |bundle, i|
      {
        id: bundle['id'],
        number: i + 1,
        capacity: Range.new(*bundle['capacity'].values_at('min', 'max')),
        tables_arrangement_id: simulation.id,
        wedding_id: simulation.wedding_id,
        name: @table_names[bundle['id']]
      }
    end

    Table.insert_all!(new_tables)
  end

  def create_seats
    records = []

    solution.each do |bundle|
      records += bundle['people_ids'].map do |guest_id|
        {
          guest_id:,
          table_id: bundle['id'],
          tables_arrangement_id: simulation.id,
          wedding_id: simulation.wedding_id,
          pinned: bundle['pinned_ids'].include?(guest_id)
        }
      end
    end
    Seat.insert_all!(records)
  end
end
