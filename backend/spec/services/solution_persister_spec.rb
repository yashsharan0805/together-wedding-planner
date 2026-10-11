# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolutionPersister do
  describe '#call' do
    let(:wedding) { create(:wedding) }
    let(:simulation) { create(:tables_arrangement, wedding:) }
    let(:guests) { create_list(:guest, 17, wedding:, group: nil) }

    let(:table_a) { simulation.reload.tables.find('6a706563-5659-49a9-bce9-918220cb77ed') }
    let(:table_b) { simulation.reload.tables.find('877d0f2d-96ba-49d1-addb-d32ce672529f') }

    let(:solution) do
      [
        {
          'id' => '6a706563-5659-49a9-bce9-918220cb77ed',
          'capacity' => { 'min' => 8, 'max' => 10 },
          'people_ids' => guests[0...8].map(&:id),
          'pinned_ids' => guests[0...2].map(&:id)
        },
        {
          'id' => '877d0f2d-96ba-49d1-addb-d32ce672529f',
          'capacity' => { 'min' => 9, 'max' => 11 },
          'people_ids' => guests[8..].map(&:id),
          'pinned_ids' => guests[8...10].map(&:id)
        }
      ]
    end

    RSpec.shared_examples 'persists the latest information received' do
      it 'stores tables information', :aggregate_failures do
        described_class.new(simulation, solution).call

        expect(simulation.tables.count).to eq(2)

        expect(table_a.capacity).to eq(8...11)
        expect(table_b.capacity).to eq(9...12)
      end

      it 'stores seats information', :aggregate_failures do
        described_class.new(simulation, solution).call

        expect(table_a.guest_ids).to match_array(guests[0...8].map(&:id))
        expect(table_a.guests.where(seats: { pinned: true }).pluck(:id)).to match_array(guests[0...2].map(&:id))

        expect(table_b.guest_ids).to match_array(guests[8..].map(&:id))
        expect(table_b.guests.where(seats: { pinned: true }).pluck(:id)).to match_array(guests[8...10].map(&:id))
      end
    end

    context 'when the solution is brand new' do
      it_behaves_like 'persists the latest information received'
    end

    context 'when a previous solution already existed' do
      before do
        old_table_1 = create(:table, id: '6a706563-5659-49a9-bce9-918220cb77ed', wedding:,
                                     tables_arrangement: simulation, name: 'Work')
        old_table_2 = create(:table, id: '877d0f2d-96ba-49d1-addb-d32ce672529f', wedding:,
                                     tables_arrangement: simulation)

        Seat.create!(table: old_table_1, wedding:, tables_arrangement: simulation, guest: guests.first, pinned: false)
        Seat.create!(table: old_table_2, wedding:, tables_arrangement: simulation, guest: guests.second, pinned: true)
      end

      it_behaves_like 'persists the latest information received'

      it 'preserves table names' do
        described_class.new(simulation, solution).call

        expect(table_a.name).to eq('Work')
      end
    end
  end
end
