# frozen_string_literal: true

require 'rails_helper'

module Buses
  RSpec.describe StatsQuery do
    let_it_be(:wedding) { create(:wedding) }
    let_it_be(:group) { create(:group) }

    around { |example| ActsAsTenant.with_tenant(wedding) { example.run } }

    shared_context 'when there are guests in multiple statuses' do
      before do
        create_list(:guest, 2, status: :considered, needs_bus: true)
        create_list(:guest, 3, status: :considered, needs_bus: false)
        create_list(:guest, 4, status: :invited, needs_bus: true) # potential
        create_list(:guest, 5, status: :invited, needs_bus: false)
        create_list(:guest, 6, status: :confirmed, needs_bus: true) # potential, confirmed
        create_list(:guest, 7, status: :confirmed, needs_bus: false)
        create_list(:guest, 8, status: :declined, needs_bus: true)
        create_list(:guest, 9, status: :declined, needs_bus: false)
        create_list(:guest, 10, status: :tentative, needs_bus: true) # potential
        create_list(:guest, 11, status: :tentative, needs_bus: false)
      end
    end

    describe '#confirmed' do
      context 'when there are no guests' do
        it { expect(described_class.new.confirmed).to be_zero }
      end

      context 'when there are guests' do
        include_context 'when there are guests in multiple statuses'
        it 'returns the number guests in confirmed status who have the bus flag enabled' do
          expect(described_class.new.confirmed).to eq(6)
        end
      end
    end

    describe '#potential' do
      context 'when there are no guests' do
        it { expect(described_class.new.potential).to be_zero }
      end

      context 'when there are guests' do
        include_context 'when there are guests in multiple statuses'
        it 'returns the number guests in potential status who have the bus flag enabled' do
          expect(described_class.new.potential).to eq(4 + 6 + 10)
        end
      end
    end
  end
end
