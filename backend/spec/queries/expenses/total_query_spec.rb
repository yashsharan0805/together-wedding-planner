# Copyright (C) 2024-2025 LibreWeddingPlanner contributors

# frozen_string_literal: true

require 'rails_helper'

module Expenses
  RSpec.describe TotalQuery do
    describe '#call' do
      let(:wedding) { create(:wedding) }
      let(:response) { described_class.new(wedding:).call }

      before do
        create_list(:guest, 2, wedding:, status: :confirmed)
        create_list(:guest, 3, wedding:, status: :considered)
        create_list(:guest, 4, wedding:, status: :invited)
        create_list(:guest, 5, wedding:, status: :tentative)
        create_list(:guest, 6, wedding:, status: :declined)
      end

      describe 'expenses' do
        context 'when there is no expense' do
          it 'returns zero in all values', :aggregate_failures do
            expect(response['total_confirmed']).to be_zero
            expect(response['total_projected']).to be_zero
            expect(response['confirmed_guests']).to eq(2)
            expect(response['projected_guests']).to eq(2 + 4 + 5)
          end
        end

        context 'when there are only fixed expenses' do
          before do
            create(:expense, :fixed, wedding:, amount: 100)
            create(:expense, :fixed, wedding:, amount: 200)
          end

          it 'returns the sum of fixed expenses', :aggregate_failures do
            expect(response['total_confirmed']).to eq(300)
            expect(response['total_projected']).to eq(300)
            expect(response['confirmed_guests']).to eq(2)
            expect(response['projected_guests']).to eq(2 + 4 + 5)
          end
        end

        context 'when there are only variable expenses' do
          before do
            create(:expense, :per_person, wedding:, amount: 100)
            create(:expense, :per_person, wedding:, amount: 200)
          end

          it 'returns zero in the values and nonzero in the count', :aggregate_failures do
            expect(response['total_confirmed']).to eq(2 * 300)
            expect(response['total_projected']).to eq(11 * 300)
            expect(response['confirmed_guests']).to eq(2)
            expect(response['projected_guests']).to eq(2 + 4 + 5)
          end
        end

        context 'when there are both fixed and variable expenses' do
          before do
            create(:expense, :fixed, wedding:, amount: 100)
            create(:expense, :fixed, wedding:, amount: 200)
            create(:expense, :per_person, wedding:, amount: 50)
          end

          it 'returns the sum of fixed and variable expenses', :aggregate_failures do
            expect(response['total_confirmed']).to eq(100 + 200 + (50 * 2))
            expect(response['total_projected']).to eq(100 + 200 + (11 * 50))
            expect(response['confirmed_guests']).to eq(2)
            expect(response['projected_guests']).to eq(2 + 4 + 5)
          end
        end
      end

      describe 'payments' do
        context 'when there are no payments' do
          it 'returns zero paid amount' do
            expect(response['total_paid']).to be_zero
          end
        end

        context 'when there are payments' do
          before do
            expense = create(:expense, :fixed, wedding:, amount: 500)
            create(:payment, expense:, wedding:, amount: 150)
            create(:payment, expense:, wedding:, amount: 350)
          end

          it 'returns the total paid amount' do
            expect(response['total_paid']).to eq(500)
          end
        end
      end
    end
  end
end
