# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Location do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:place_id) }

    describe 'latitude' do
      it { is_expected.to validate_presence_of(:latitude) }
      it { is_expected.to validate_numericality_of(:latitude).is_in(-90..90) }
    end

    describe 'longitude' do
      it { is_expected.to validate_presence_of(:longitude) }
      it { is_expected.to validate_numericality_of(:longitude).is_in(-180..180) }
    end

    it { is_expected.to validate_presence_of(:label) }
  end
end
