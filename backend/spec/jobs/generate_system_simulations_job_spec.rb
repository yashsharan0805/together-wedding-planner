# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateSystemSimulationsJob do
  describe '#perform' do
    let!(:viking_wedding) { create(:wedding) }
    let!(:roman_wedding) { create(:wedding) }
    let!(:christian_wedding) { create(:wedding) }

    before do
      allow(WeddingPlanner.redis).to receive(:get).with(%r{wedding/simulations/version/.*}).and_return(35)
      allow(TaskProcessingJob).to receive(:perform_async)

      viking_wedding.tables_arrangements.create!(system: true, status: :completed)
    end

    it 'generates a system simulation for weddings without one, and schedules an optimization job',
       :aggregate_failures do
      expect { described_class.new.perform }.to change(TablesArrangement, :count).by(2)

      expect(viking_wedding.tables_arrangements.where(system: true).sole.status).to eq 'completed'
      expect(roman_wedding.tables_arrangements.where(system: true).sole.status).to eq 'not_started'
      expect(christian_wedding.tables_arrangements.where(system: true).sole.status).to eq 'not_started'

      expect(TaskProcessingJob).to have_received(:perform_async).twice
    end
  end
end
