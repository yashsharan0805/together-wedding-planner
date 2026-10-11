# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_bus_context'

module Reports
  RSpec.describe BusGroupsReport do
    let(:wedding) { create(:wedding) }

    include_context 'when several groups have guests with different bus needs'

    describe '#to_h' do
      let(:report) { described_class.new(wedding:).to_h }
      let(:rows) { report[:rows] }
      let(:columns) { report[:columns] }

      it 'includes the columns needed for the report', :aggregate_failures do
        expect(columns.count).to eq(2)

        expect(columns[0]).to eq(header: 'Group', field: :group)
        expect(columns[1]).to eq(header: 'Guest count', field: :guest_count)
      end

      it 'returns a row for each guest', :aggregate_failures do
        expect(rows.count).to eq(2)

        expect(rows.dig(0, 'group')).to eq('School')
        expect(rows.dig(0, 'guest_count')).to eq(3)

        expect(rows.dig(1, 'group')).to eq('Work')
        expect(rows.dig(1, 'guest_count')).to eq(1)
      end
    end
  end
end
