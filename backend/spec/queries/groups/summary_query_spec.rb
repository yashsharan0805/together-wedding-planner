# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'

module Groups
  RSpec.describe SummaryQuery do
    describe '#call' do
      let(:wedding) { create(:wedding) }

      subject(:result) { described_class.new.call }

      context 'when there are no groups' do
        it { is_expected.to eq([]) }
      end

      context 'when groups are defined' do
        let!(:parent) { create(:group, name: 'Friends', icon: 'icon-1', color: '#FF0000', wedding:) }
        let!(:child) { create(:group, name: 'Family', icon: 'icon-2', color: '#00FF00', parent:, wedding:) }

        context 'when there are no guests' do
          it 'returns the summary of groups' do
            expect(result).to contain_exactly(
              { 'id' => parent.id,
                'name' => 'Friends',
                'icon' => 'icon-1',
                'parent_id' => nil,
                'color' => '#FF0000',
                'total' => 0,
                'considered' => 0,
                'invited' => 0,
                'confirmed' => 0,
                'declined' => 0,
                'tentative' => 0 },
              { 'id' => child.id,
                'name' => 'Family',
                'icon' => 'icon-2',
                'parent_id' => parent.id,
                'color' => '#00FF00',
                'total' => 0,
                'considered' => 0,
                'invited' => 0,
                'confirmed' => 0,
                'declined' => 0,
                'tentative' => 0 }
            )
          end
        end

        context 'when there are guests' do
          before do
            # Parent group
            create_list(:guest, 2, group: parent, status: :considered, wedding:)
            create_list(:guest, 3, group: parent, status: :invited, wedding:)
            create_list(:guest, 4, group: parent, status: :confirmed, wedding:)
            create_list(:guest, 5, group: parent, status: :declined, wedding:)
            create_list(:guest, 6, group: parent, status: :tentative, wedding:)

            # Child group
            create_list(:guest, 7, group: child, status: :considered, wedding:)
            create_list(:guest, 8, group: child, status: :invited, wedding:)
            create_list(:guest, 9, group: child, status: :confirmed, wedding:)
            create_list(:guest, 10, group: child, status: :declined, wedding:)
            create_list(:guest, 11, group: child, status: :tentative, wedding:)
          end

          it 'returns the summary of groups' do
            expect(result).to contain_exactly(
              {
                'id' => parent.id,
                'name' => 'Friends',
                'icon' => 'icon-1',
                'parent_id' => nil,
                'color' => '#FF0000',
                'total' => 20,
                'considered' => 2,
                'invited' => 3,
                'confirmed' => 4,
                'declined' => 5,
                'tentative' => 6
              },
              {
                'id' => child.id,
                'name' => 'Family',
                'icon' => 'icon-2',
                'parent_id' => parent.id,
                'color' => '#00FF00',
                'total' => 45,
                'considered' => 7,
                'invited' => 8,
                'confirmed' => 9,
                'declined' => 10,
                'tentative' => 11
              }
            )
          end
        end
      end
    end
  end
end
