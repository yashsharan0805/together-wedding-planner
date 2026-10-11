# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'
module Tables
  RSpec.describe DiscomfortCalculator do
    let(:calculator) { described_class.new(table:) }

    let(:wedding) { create(:wedding) }
    let(:family) { create(:group, name: 'family', wedding:) }
    let(:friends) { create(:group, name: 'friends', wedding:) }
    let(:work) { create(:group, name: 'work', wedding:) }
    let(:school) { create(:group, name: 'school', wedding:) }

    describe '#calculate' do
      before do
        allow(calculator).to receive_messages(table_size_penalty: 2, cohesion_penalty: 5, invitations_penalty: 4)
      end

      let(:table) { Table.new(create_list(:guest, 6, wedding:)) }

      it 'returns the sum of the table size penalty and the average cohesion penalty', :aggregate_failures do
        expect(calculator.calculate).to eq(11)
        expect(calculator.breakdown).to eq(table_size_penalty: 2, cohesion_penalty: 5, invitations_penalty: 4)
      end
    end

    describe '#table_size_penalty' do
      before do
        table.min_per_table = 5
        table.max_per_table = 7
      end

      context 'when the table is empty' do
        let(:table) { Table.new([]) }

        it 'returns 5 * min capacity of the table' do
          expect(calculator.send(:table_size_penalty)).to eq(25)
        end
      end

      context 'when the number of guests is in the lower bound' do
        let(:table) { Table.new(create_list(:guest, 5, wedding:)) }

        it { expect(calculator.send(:table_size_penalty)).to eq(0) }
      end

      context 'when the number of guests is within the table size limits' do
        let(:table) { Table.new(create_list(:guest, 6, wedding:)) }

        it { expect(calculator.send(:table_size_penalty)).to eq(0) }
      end

      context 'when the number of guests is in the upper bound' do
        let(:table) { Table.new(create_list(:guest, 7, wedding:)) }

        it { expect(calculator.send(:table_size_penalty)).to eq(0) }
      end

      context 'when the number of guests is one unit below the lower bound' do
        let(:table) { Table.new(create_list(:guest, 4, wedding:)) }

        it { expect(calculator.send(:table_size_penalty)).to eq(5) }
      end

      context 'when the number of guests is two units below the lower bound' do
        let(:table) { Table.new(create_list(:guest, 3, wedding:)) }

        it { expect(calculator.send(:table_size_penalty)).to eq(10) }
      end

      context 'when the number of guests is one unit above the upper bound' do
        let(:table) { Table.new(create_list(:guest, 8, wedding:)) }

        it { expect(calculator.send(:table_size_penalty)).to eq(5) }
      end

      context 'when the number of guests is two units above the upper bound' do
        let(:table) { Table.new(create_list(:guest, 9, wedding:)) }

        it { expect(calculator.send(:table_size_penalty)).to eq(10) }
      end
    end

    describe '#cohesion_penalty' do
      let(:calculator) { described_class.new(table:, hierarchy:) }
      let(:table) { Table.new(guests) }

      context 'when the table is empty' do
        let(:guests) { [] }
        let(:hierarchy) { instance_double(AffinityGroupsHierarchy) }

        it 'returns 0 as cohesion penalty' do
          expect(calculator.send(:cohesion_penalty)).to eq(0)
        end
      end

      context 'when all guests belong to the same group' do
        let(:guests) { create_list(:guest, 6, group: family, wedding:) }
        let(:hierarchy) { instance_double(AffinityGroupsHierarchy, discomfort: 0) }

        it 'returns 0 as cohesion penalty' do
          expect(calculator.send(:cohesion_penalty)).to eq(0)
        end
      end

      context 'when guests belong to two different groups with discomfort 1' do
        let(:guests) do
          create_list(:guest, 3, group: family, wedding:) +
            create_list(:guest, 3, group: friends, wedding:)
        end
        let(:hierarchy) do
          instance_double(AffinityGroupsHierarchy, discomfort: 1)
        end

        it 'calculates the correct cohesion penalty' do
          # 3 from family, 3 from friends: 3*3*1 = 9 discomfort
          expect(calculator.send(:cohesion_penalty)).to eq(10 * (9.0 / 6))
        end
      end

      context 'when guests belong to three groups with different discomforts' do
        let(:guests) do
          create_list(:guest, 2, group: family, wedding:) +
            create_list(:guest, 2, group: friends, wedding:) +
            create_list(:guest, 2, group: work, wedding:)
        end
        let(:hierarchy) do
          instance_double(AffinityGroupsHierarchy)
        end

        before do
          allow(hierarchy).to receive(:discomfort).with(family.id, friends.id).and_return(0.5)
          allow(hierarchy).to receive(:discomfort).with(family.id, work.id).and_return(1)
          allow(hierarchy).to receive(:discomfort).with(friends.id, work.id).and_return(0.2)
          allow(hierarchy).to receive(:discomfort).with(friends.id, family.id).and_return(0.5)
          allow(hierarchy).to receive(:discomfort).with(work.id, family.id).and_return(1)
          allow(hierarchy).to receive(:discomfort).with(work.id, friends.id).and_return(0.2)
        end

        it 'calculates the correct cohesion penalty' do
          # pairs: (family, friends): 2*2*0.5 = 2
          #        (family, work):    2*2*1   = 4
          #        (friends, work):   2*2*0.2 = 0.8
          # total discomfort = 2 + 4 + 0.8 = 6.8

          expect(calculator.send(:cohesion_penalty)).to eq(10 * (6.8 / 6))
        end
      end
    end

    describe '#invitations_penalty' do
      let(:invitation_a) { create(:invitation) }
      let(:invitation_b) { create(:invitation) }
      let(:invitation_c) { create(:invitation) }

      let(:table) do
        Table.new(create_list(:guest, 2, invitation: invitation_a, wedding:) +
          create_list(:guest, 3, invitation: invitation_b, wedding:) +
          create_list(:guest, 4, invitation: invitation_c, wedding:))
      end

      context 'when the table is empty' do
        let(:table) { Table.new([]) }

        it { expect(calculator.send(:invitations_penalty)).to eq(0) }
      end

      context 'when the table contains all members of an invitation' do
        it 'returns 0 as penalty' do
          expect(calculator.send(:invitations_penalty)).to eq(0)
        end
      end

      context 'when there is an additional guest of one of the invitations that is not included' do
        before do
          create(:guest, invitation: invitation_a, wedding:)
        end

        it 'returns the penalty for the missing guest' do
          expect(calculator.send(:invitations_penalty)).to eq(2)
        end
      end

      context 'when there are multiple guests missing from different invitations' do
        before do
          create(:guest, invitation: invitation_b, wedding:)
          create(:guest, invitation: invitation_c, wedding:)
        end

        it 'returns 2x # of guests left out as the total penalty for all missing guests' do
          expect(calculator.send(:invitations_penalty)).to eq(4)
        end
      end
    end
  end
end
