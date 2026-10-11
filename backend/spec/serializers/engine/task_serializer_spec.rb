# frozen_string_literal: true

require 'rails_helper'

module Engine
  RSpec.describe TaskSerializer do
    let(:wedding) { create(:wedding) }
    let(:simulation) { create(:tables_arrangement, wedding:) }

    let(:group_a) { create(:group, wedding:) }
    let(:group_b) { create(:group, wedding:) }
    let(:group_c) { create(:group, wedding:) }

    let(:guests_a) { create_list(:guest, 3, wedding:, group: group_a) }
    let(:guests_b) { create_list(:guest, 4, wedding:, group: group_b) }

    let(:red_invitation) { create(:invitation, wedding:) }
    let(:blue_invitation) { create(:invitation, wedding:) }
    let(:green_invitation) { create(:invitation, wedding:) }

    let(:result) { described_class.new(simulation.id).call }

    before do
      allow(WeddingPlanner.redis).to receive(:get).with("wedding/simulations/version/#{wedding.id}").and_return(35)

      table_a = create(:table, wedding:, tables_arrangement: simulation, capacity: 8..10)
      table_b = create(:table, wedding:, tables_arrangement: simulation, capacity: 13..13)

      guests_a.each { wedding.seats.create!(wedding:, table: table_a, tables_arrangement: simulation, guest: it, pinned: true) }
      guests_b.each { wedding.seats.create!(wedding:, table: table_b, tables_arrangement: simulation, guest: it) }

      GroupAffinity.create!(group_a:, group_b:, discomfort: 0.2)
      GroupAffinity.create!(group_a:, group_b: group_c, discomfort: 1) # Ignored because matches default

      guests_a.first.update!(invitation: red_invitation)
      guests_a.second.update!(invitation: red_invitation)

      guests_b.first.update!(invitation: blue_invitation)
      guests_b.second.update!(invitation: blue_invitation)
      guests_b.third.update!(invitation: blue_invitation)

      guests_b.last.update!(invitation: green_invitation) # ignored because there is one guest only

      create(:table_type, wedding:, availability: 4, capacity: 12..12)
      create(:table_type, wedding:, availability: nil, capacity: 8..10)
    end

    describe 'id' do
      it { expect(result['id']).to eq(simulation.id) }
    end

    describe 'version' do
      it { expect(result['version']).to eq(35) }
    end

    describe 'groups' do
      it 'includes the id and the list of guests therein' do
        expect(result['groups']).to contain_exactly(
          { 'id' => group_a.id, 'people_ids' => match_array(guests_a.map(&:id)) },
          { 'id' => group_b.id, 'people_ids' => match_array(guests_b.map(&:id)) }
        )
      end

      context 'when there are guests without group' do
        it 'creates fake group IDs with a single guest', :aggregate_failures do
          ungrouped_a = create(:guest, wedding:, status: :invited)
          ungrouped_b = create(:guest, wedding:, status: :invited)

          expect(result['groups'].pluck('id').uniq.count).to eq(4)
          expect(result['groups']).to contain_exactly(
            { 'id' => group_a.id, 'people_ids' => match_array(guests_a.map(&:id)) },
            { 'id' => group_b.id, 'people_ids' => match_array(guests_b.map(&:id)) },
            { 'id' => kind_of(String), 'people_ids' => [ungrouped_a.id] },
            { 'id' => kind_of(String), 'people_ids' => [ungrouped_b.id] }
          )
        end
      end
    end

    describe 'discomfort' do
      it 'includes a list with the discomforts stored per pair of groups' do
        expect(result['affinities']).to contain_exactly(
          {
            'group_ids' => contain_exactly(group_a.id, group_b.id),
            'discomfort' => '0.2'
          }
        )
      end
    end

    describe 'binds' do
      it 'includes the groups of people in the same invitation' do
        expect(result['binds']).to contain_exactly(
          { 'people_ids' => match_array(guests_a.first(2).map(&:id)) },
          { 'people_ids' => match_array(guests_b.first(3).map(&:id)) }
        )
      end
    end

    describe 'bundles' do
      it 'includes information about the table types available' do
        expect(result['bundles']).to contain_exactly(
          { 'units' => 4, 'capacity' => { 'min' => 12, 'max' => 12 } },
          { 'units' => nil, 'capacity' => { 'min' => 8, 'max' => 10 } }
        )
      end
    end

    describe 'solution' do
      let(:solution) { result['solution'] }

      describe 'length' do
        it { expect(solution.count).to eq(2) }
      end

      describe 'id' do
        it 'includes the id of the ActiveRecord Table object' do
          expect(solution.pluck('id')).to match_array(simulation.table_ids)
        end
      end

      describe 'capacity' do
        it 'includes the capacity limits of each table' do
          expect(solution.pluck('capacity')).to eq([
                                                     { 'min' => 8, 'max' => 10 },
                                                     { 'min' => 13, 'max' => 13 }
                                                   ])
        end
      end

      describe 'people_ids' do
        it 'includes the ids of the people included in each table' do
          expect(solution.first['people_ids']).to match_array(guests_a.pluck(:id))
          expect(solution.second['people_ids']).to match_array(guests_b.pluck(:id))
        end
      end

      describe 'pinned_ids' do
        it 'includes the ids of the pinned people included in each table' do
          expect(solution.first['pinned_ids']).to match_array(guests_a.pluck(:id))
          expect(solution.second['pinned_ids']).to be_empty
        end
      end
    end
  end
end
