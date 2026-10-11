# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'

module Tables
  RSpec.describe Distribution do
    let(:tables_arrangement) { TablesArrangement.create! }
    let(:table_types) { [create(:table_type)] }
    let(:wedding) { ActsAsTenant.current_tenant }

    around do |example|
      ActsAsTenant.with_tenant(create(:wedding)) do
        example.run
      end
    end

    describe '.load' do
      let(:guests) { create_list(:guest, 10, wedding:) }

      before do
        wedding.table_types.insert_all([
                                         { capacity: 4..6, availability: 1 },
                                         { capacity: 5..7, availability: 2 }
                                       ])

        foo_table = tables_arrangement.tables.create!(number: 1, capacity: 4..6, name: 'Foo', wedding:)
        bar_table = tables_arrangement.tables.create!(number: 2, capacity: 5..7, name: 'Bar', wedding:)

        tables_arrangement.seats.insert_all(
          guests.first(5).map { { guest_id: it.id, table_id: foo_table.id, pinned: true } } +
                  guests.last(5).map { { guest_id: it.id, table_id: bar_table.id, pinned: false } }
        )
      end

      it 'loads a persisted TableArrangement object and its tables and guests into a Distribution',
         :aggregate_failures do
        distribution = described_class.load(tables_arrangement.id)

        expect(distribution).to be_a(described_class)
        expect(distribution.tables.count).to eq(2)
        expect(distribution.tables).to all(be_a(Table))
        expect(distribution.table_types.count).to eq(2)

        foo_table = distribution.tables.find { it.number == 1 }
        expect(foo_table.name).to eq('Foo')
        expect(foo_table.min_per_table).to eq(4)
        expect(foo_table.max_per_table).to eq(6)
        expect(foo_table.map(&:id)).to match_array(tables_arrangement.tables.find_by!(number: 1).guest_ids)
        expect(foo_table.map(&:pinned)).to all(be_truthy)

        bar_table = distribution.tables.find { it.number == 2 }
        expect(bar_table.name).to eq('Bar')
        expect(bar_table.min_per_table).to eq(5)
        expect(bar_table.max_per_table).to eq(7)
        expect(bar_table.map(&:id)).to match_array(tables_arrangement.tables.find_by!(number: 2).guest_ids)
        expect(bar_table.map(&:pinned)).to all(be_falsey)
      end
    end

    describe '#discomfort' do
      let(:distribution) do
        described_class.new(table_types:, tables_arrangement_id: tables_arrangement.id)
      end

      context 'when there are no tables' do
        it 'returns 0' do
          expect(distribution.discomfort).to eq(0)
        end
      end

      context 'when there are tables' do
        it 'calculates the total discomfort as the sum of the discomfort of each table' do
          friends_table = Table.new([1, 2, 3])
          family_table = Table.new([4, 5, 6])

          allow(DiscomfortCalculator).to receive(:new)
            .with(hash_including(table: friends_table))
            .and_return(instance_double(DiscomfortCalculator, calculate: 2.5))
          allow(DiscomfortCalculator).to receive(:new)
            .with(hash_including(table: family_table))
            .and_return(instance_double(DiscomfortCalculator, calculate: 3))

          distribution.tables = [friends_table, family_table]
          expect(distribution.discomfort).to eq(5.5)
        end
      end
    end
  end
end
