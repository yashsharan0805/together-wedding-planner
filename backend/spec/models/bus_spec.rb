# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bus do
  let(:wedding) { create(:wedding) }

  describe 'validations' do
    describe 'seats' do
      subject { build(:bus, wedding:) }

      it { is_expected.to validate_numericality_of(:seats).is_greater_than(0).only_integer }
    end
  end

  describe 'scopes' do
    describe '.with_number' do
      it 'assigns a consecutive number to each bus returned' do
        create_list(:bus, 3, wedding:)

        expect(described_class.with_number.map(&:number)).to eq([1, 2, 3])
      end
    end
  end
end
