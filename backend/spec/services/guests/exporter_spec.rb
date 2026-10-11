# frozen_string_literal: true

require 'rails_helper'

module Guests
  RSpec.describe Exporter do
    describe '#call' do
      let(:wedding) { create(:wedding) }
      let(:csv) { CSV.parse(described_class.new(wedding:).call, headers: true) }

      describe 'row count' do
        before do
          create_list(:guest, 3, wedding:)
        end

        it 'has as many rows as guests in the wedding' do
          expect(csv.count).to eq(3)
        end
      end

      describe 'row content' do
        let(:row) { csv.first }

        before do
          create(
            :guest,
            wedding:,
            name: 'John Snow',
            group: create(:group, wedding:, name: 'Night Watch'),
            status: :considered,
            menu_choice: :meat,
            menu_restrictions: 'Allergic to peanuts',
            special_requests: 'Need a wheelchair',
            needs_bus: false
          )
        end

        context 'when the bus management setting is disabled' do
          before do
            wedding.settings.update!(bus_management: false)
          end

          it 'has the expected headers' do
            expect(csv.headers).to contain_exactly('Name', 'Group', 'Status', 'Menu choice', 'Menu restrictions',
                                                   'Special requests')
          end

          it 'assigns the right value to each column', :aggregate_failures do
            expect(row['Name']).to eq('John Snow')
            expect(row['Group']).to eq('Night Watch')
            expect(row['Status']).to eq('considered')
            expect(row['Menu choice']).to eq('meat')
            expect(row['Menu restrictions']).to eq('Allergic to peanuts')
            expect(row['Special requests']).to eq('Need a wheelchair')
          end
        end

        context 'when the bus management setting is enabled' do
          before do
            wedding.settings.update!(bus_management: true)
          end

          it 'has the expected headers' do
            expect(csv.headers).to contain_exactly('Name', 'Group', 'Status', 'Menu choice', 'Menu restrictions',
                                                   'Needs bus', 'Special requests')
          end

          it "assigns the 'Needs bus' column properly" do
            expect(row['Needs bus']).to eq('false')
          end
        end
      end
    end
  end
end
