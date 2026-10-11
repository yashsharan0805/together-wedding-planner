# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TablesArrangement do
  subject(:tables_arrangement) { described_class.new(wedding: create(:wedding)) }

  describe 'validations' do
    describe 'status' do
      it { is_expected.to validate_inclusion_of(:status).in_array(%w[not_started in_progress completed error]) }
      it { is_expected.to validate_uniqueness_of(:wedding_id).ignoring_case_sensitivity }
      it { is_expected.to validate_presence_of(:wedding_id) }
    end
  end

  describe '#recalculate_discomfort' do
    let(:wedding) { create(:wedding) }

    before do
      allow(Tables::DiscomfortCalculator).to receive(:new).and_return(
        instance_double(Tables::DiscomfortCalculator, calculate: 55),
        instance_double(Tables::DiscomfortCalculator, calculate: 100)
      )
    end

    it 'recalculates and persists the discomfort using the latest affinities' do
      tables_arrangement = create(:tables_arrangement, wedding:, discomfort: 100)
      create_list(:table, 2, tables_arrangement:, wedding:)

      tables_arrangement.recalculate_discomfort!

      expect(tables_arrangement.discomfort).to eq 155
    end
  end

  describe '#refresh_guests!' do
    let(:wedding) { create(:wedding) }
    let(:simulation) { create(:tables_arrangement, wedding:) }

    let!(:guest_a) { create(:guest, wedding:, name: 'Guest A', status: :invited) }
    let!(:guest_b) { create(:guest, wedding:, name: 'Guest B', status: :confirmed) }
    let!(:guest_c) { create(:guest, wedding:, name: 'Guest C', status: :declined) }
    let!(:table_1) { simulation.tables.create!(number: 1, wedding:, capacity: 8..10) }
    let!(:table_2) { simulation.tables.create!(number: 2, wedding:, capacity: 10..12) }

    before do
      simulation.seats.insert_all([
                                    { guest_id: guest_a.id, table_id: table_1.id, wedding_id: wedding.id },
                                    { guest_id: guest_c.id, table_id: table_2.id, wedding_id: wedding.id }
                                  ])
    end

    it 'removes seats for guests that are non-potential and adds seats for missing potential ones',
       :aggregate_failures do
      simulation.refresh_guests!

      expect(simulation.seats.pluck(:guest_id)).to contain_exactly(guest_a.id, guest_b.id)
      expect(simulation.seats.pluck(:table_id) - [table_1.id, table_2.id]).to be_empty
    end

    context 'when the simulation is new and has no tables' do
      before do
        simulation.reset!
      end

      it 'does nothing', :aggregate_failures do
        simulation.refresh_guests!

        expect(simulation.seats.count).to eq(0)
        expect(simulation.tables.count).to eq(0)
      end
    end
  end

  describe '#reset!' do
    let(:wedding) { create(:wedding) }
    let(:tables_arrangement) { create(:tables_arrangement, status: :completed) }

    around do |example|
      ActsAsTenant.with_tenant(wedding) { example.run }
    end

    before do
      create_list(:table, 2, wedding:, tables_arrangement:)
      create_list(:guest, 10, status: :confirmed, wedding:)
    end

    it 'removes all tables and seats, and sets the status as not_started' do
      expect { tables_arrangement.reset! }
          .to change { tables_arrangement.tables.count }.from(2).to(0)
          .and change { tables_arrangement.seats.count }.from(10).to(0)
          .and change(tables_arrangement, :status).from('completed').to('not_started')
    end
  end
end
