# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_bus_context'

module Reports
  RSpec.describe BusNeedsReport do
    let(:wedding) { create(:wedding) }

    include_context 'when several groups have guests with different bus needs'

    describe '#to_h' do
      let(:rows) { report[:rows] }
      let(:columns) { report[:columns] }

      context 'when looking for guests that need bus' do
        let(:report) { described_class.new(wedding:, needs_bus: true).to_h }

        it 'includes the columns needed for the report', :aggregate_failures do
          expect(columns.count).to eq(2)

          expect(columns[0]).to eq(header: 'Name', field: :name)
          expect(columns[1]).to eq(header: 'Group', field: :group)
        end

        it 'returns a row for each potential guest that needs bus', :aggregate_failures do
          expect(rows.count).to eq(4)

          expect(rows.dig(0, 'name')).to eq('Charlie')
          expect(rows.dig(0, 'group')).to eq('School')

          expect(rows.dig(1, 'name')).to eq('Erin')
          expect(rows.dig(1, 'group')).to eq('School')

          expect(rows.dig(2, 'name')).to eq('Frank')
          expect(rows.dig(2, 'group')).to eq('School')

          expect(rows.dig(3, 'name')).to eq('Alice')
          expect(rows.dig(3, 'group')).to eq('Work')
        end
      end

      context 'when looking for guests that do not need bus' do
        let(:report) { described_class.new(wedding:, needs_bus: false).to_h }

        it 'returns a row for each potential guest that does not need bus', :aggregate_failures do
          expect(rows.count).to eq(2)

          expect(rows.dig(0, 'name')).to eq('Grace')
          expect(rows.dig(0, 'group')).to eq('School')

          expect(rows.dig(1, 'name')).to eq('Bob')
          expect(rows.dig(1, 'group')).to eq('Work')
        end
      end
    end
  end
end
