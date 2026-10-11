# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BusQuote do
  describe 'validations' do
    it { is_expected.to belong_to(:bus_trip) }
    it { is_expected.to validate_presence_of(:company) }

    describe 'prices' do
      subject(:quote) { build(:bus_quote, wedding: create(:wedding)) }

      it { is_expected.to validate_presence_of(:prices) }
      it { is_expected.to allow_value([{ 'capacity' =>  4, 'price' => 100 }]).for(:prices) }
      it { is_expected.to allow_value([{ 'capacity' =>  4, 'price' => 100.0 }]).for(:prices) }

      it {
        expect(quote).to allow_value([{ 'capacity' => 4, 'price' => 100 },
                                      { 'capacity' => 15, 'price' => 300 }]).for(:prices)
      }

      it { is_expected.not_to allow_value([]).for(:prices) }
      it { is_expected.not_to allow_value([{ 'capacity' => 4, 'price' => 100.0, foo: 4 }]).for(:prices) }

      it {
        expect(quote).not_to allow_value([{ 'capacity' => 4, 'price' => 100.0 },
                                          { 'capacity' => 4, 'price' => 200 }]).for(:prices)
      }

      it { is_expected.not_to allow_value([{ 'capacity' => 4.0, 'price' => 100 }]).for(:prices) }
      it { is_expected.not_to allow_value([{ 'capacity' =>  4, 'price' =>  0 }]).for(:prices) }
      it { is_expected.not_to allow_value([{ 'capacity' =>  4, 'price' =>  -1 }]).for(:prices) }
      it { is_expected.not_to allow_value([{ 'capacity' =>  4, 'price' =>  nil }]).for(:prices) }
      it { is_expected.not_to allow_value([{ 'capacity' =>  0, 'price' =>  10 }]).for(:prices) }
      it { is_expected.not_to allow_value([{ 'capacity' => -1, 'price' => 10 }]).for(:prices) }
      it { is_expected.not_to allow_value([{ 'capacity' => nil, 'price' => 10 }]).for(:prices) }
      it { is_expected.not_to allow_value([{ 'capacity' => 4, 'price' => :a }]).for(:prices) }
      it { is_expected.not_to allow_value([{ 'capacity' => :a, 'price' => 4 }]).for(:prices) }
      it { is_expected.not_to allow_value([{ 'capacity' => 4, 'price' => { foo: 4 } }]).for(:prices) }
    end
  end
end
