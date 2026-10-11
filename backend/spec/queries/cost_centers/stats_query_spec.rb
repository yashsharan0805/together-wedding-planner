# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'

module CostCenters
  RSpec.describe StatsQuery do
    describe '#call' do
      let(:wedding) { create(:wedding) }
      let(:expense) { create(:expense, wedding:) }
      let(:result) { described_class.new.call }

      around do |example|
        ActsAsTenant.with_tenant(wedding) do
          example.run
        end
      end

      context 'when there is no payment or cost center' do
        it 'returns an empty array' do
          expect(result).to eq([])
        end
      end

      context 'when there are only payments associated to no cost center' do
        before do
          create(:payment, expense:, wedding:, amount: 100)
          create(:payment, expense:, wedding:, amount: 20.5)
        end

        it 'returns the sum and count of expenses' do
          expect(result).to eq([
                                 {
                                   'name' => nil,
                                   'count' => 2,
                                   'sum' => 120.5
                                 }
                               ])
        end
      end

      context 'when there are a mix of payments, associated to a cost center or not' do
        before do
          create(:cost_center, wedding:, name: 'Foo').tap do |cost_center|
            create(:payment, expense:, cost_center:, wedding:, amount: 100)
            create(:payment, expense:, cost_center:, wedding:, amount: 200)
          end

          create(:cost_center, wedding:, name: 'Bar').tap do |cost_center|
            create(:payment, expense:, cost_center:, wedding:, amount: 20)
            create(:payment, expense:, cost_center:, wedding:, amount: 35)
            create(:payment, expense:, cost_center:, wedding:, amount: 10)
          end

          create(:payment, expense:, cost_center: nil, wedding:, amount: 105)
          create(:payment, expense:, cost_center: nil, wedding:, amount: 60)
          create(:payment, expense:, cost_center: nil, wedding:, amount: 5)
          create(:payment, expense:, cost_center: nil, wedding:, amount: 22)
        end

        it 'returns the sum and count of expeneses per cost center' do
          expect(result).to eq([
                                 {
                                   'name' => nil,
                                   'count' => 4,
                                   'sum' => 192.0
                                 },
                                 {
                                   'name' => 'Bar',
                                   'count' => 3,
                                   'sum' => 65.0
                                 },
                                 {
                                   'name' => 'Foo',
                                   'count' => 2,
                                   'sum' => 300.0
                                 }
                               ])
        end
      end
    end
  end
end
