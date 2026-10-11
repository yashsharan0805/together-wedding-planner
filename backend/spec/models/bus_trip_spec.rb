# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BusTrip do
  subject { build(:bus_trip, wedding: create(:wedding)) }

  describe 'validations' do
    it { is_expected.to belong_to(:wedding) }
    it { is_expected.to have_many(:bus_quotes).dependent(:delete_all) }
    it { is_expected.to validate_presence_of(:name) }
  end
end
