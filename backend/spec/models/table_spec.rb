# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_examples'

RSpec.describe Table do
  let(:wedding) { create(:wedding) }
  let(:tables_arrangement) { create(:tables_arrangement, wedding:) }

  describe 'validations' do
    subject { build(:table, wedding:, tables_arrangement:) }

    describe 'capacity' do
      it { is_expected.to validate_presence_of(:capacity) }

      it_behaves_like 'a range representing table capacity'
    end

    describe 'number' do
      it { is_expected.to validate_numericality_of(:number).only_integer.is_greater_than(0) }
      it { is_expected.to validate_uniqueness_of(:number).scoped_to(%i[wedding_id tables_arrangement_id]) }
    end
  end

  describe 'callbacks' do
    describe '#set_number' do
      let(:wedding) { create(:wedding) }
      let(:tables_arrangement) { create(:tables_arrangement, wedding:) }

      context 'when there is no table' do
        it { expect(create(:table, wedding:, number: nil, tables_arrangement:).number).to eq(1) }
      end

      context 'when there are other tables' do
        before do
          create(:table, wedding:, tables_arrangement:, number: 16)
        end

        it { expect(create(:table, wedding:, number: nil, tables_arrangement:).number).to eq(17) }
      end
    end

    describe '#nullify_title' do
      it { expect(create(:table, wedding:, tables_arrangement:, name: nil).name).to be_nil }
      it { expect(create(:table, wedding:, tables_arrangement:, name: '').name).to be_nil }
      it { expect(create(:table, wedding:, tables_arrangement:, name: '   ').name).to be_nil }
      it { expect(create(:table, wedding:, tables_arrangement:, name: 'foo').name).to eq('foo') }
      it { expect(create(:table, wedding:, tables_arrangement:, name: '  foo  ').name).to eq('foo') }
    end
  end
end
